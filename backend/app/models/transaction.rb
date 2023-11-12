class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :account

  after_create :track_modifications
  before_destroy :before_delete_action


  # def validate_transaction
  #   raise StandardError.new("Cannot add a transaction in past date of account opening") if self.account.opening_date > self.date
  # end

  def before_delete_action
    return if self.account.nil?
    self.account.update_balance(self, 'delete')
    LazyWorker.perform_async("update_subsequent", {"transaction_id" => self.id, "action" => "delete"}) unless self.pseudo
    if [PAID_BY_YOU, SETTLED_BY_PARTY, SETTLED_BY_YOU].include? self.ttype
      owed_acc = Account.find_by_id(self.party)
      owed_acc.update_balance(self, 'delete')
      # LazyWorker.perform_async("update_subsequent", {"transaction_id" => self.id, "account_id"=> owed_acc.id})
    end
    self.delete_split_transactions if self.ttype == SPLIT
  end

  def card
    Card.find_by_id(self.card_id)
  end

  def track_modifications
    return if self.account_opening?
    self.update_t_order
    return if self.pseudo
    self.reload.account.update_balance(self)
    # self.account.update_daily_log(self)
    if [DEBIT, CREDIT, SPLIT].include? self.ttype
      balance_before, new_tr = self.get_balance_before
      self.balance_before = balance_before
      self.balance_after = balance_before + self.get_difference(self.account)
    else
      balance_before, new_tr = self.get_balance_before(Account.find_by_id(self.party))
      self.o_balance_before = balance_before
      self.o_balance_after = balance_before + self.get_difference(self.account)
    end
    
    self.save!
    if [DEBIT, PAID_BY_PARTY].include? self.ttype
      self.update_budgets
    end
    LazyWorker.perform_async("update_subsequent", {"transaction_id" => self.id}) if new_tr
    if [PAID_BY_YOU, SETTLED_BY_PARTY, SETTLED_BY_YOU].include? self.ttype
      owed_acc = Account.find_by_id(self.party)
      owed_acc.update_balance(self)
      # owed_acc.update_daily_log(self)
      LazyWorker.perform_async("update_subsequent", {"transaction_id" => self.id, "account_id"=> owed_acc.id}) if new_tr
    end
  end

  def self.account_opening(amount, date, account)
    tr = Transaction.new(amount: amount, ttype: CREDIT, date: date, user: account.user, account: account,
                         meta: { "opening_transaction" => true }, comments: "account opening transaction",
                        balance_before: 0, balance_after: amount)
    tr.save!
    return tr
  end

  def update_t_order
    today = self.account.transactions.where(date: self.date)
    if today.present?
      t_order = today.order(t_order: :desc).first.t_order + 1
    else
      t_order = 1
    end
    self.t_order = t_order
    self.save!
  end

  def get_difference(account)
    if account.owed
      if [PAID_BY_YOU, SETTLED_BY_YOU].include? self.ttype
        return self.amount
      else
        return -self.amount
      end
    else
      if CREDIT_TRANSACTIONS.include? self.ttype
        return self.amount
      else
        return -self.amount
      end
    end

  end

  def get_subsequent_transactions(account=self.account)
    account.transactions.where('date > ? OR (date = ? AND t_order > ?)', self.date, self.date, self.t_order)
  end

  def update_subsequent(action, account=self.account)
    amount = action == 'delete' ? - self.get_difference(account) : self.get_difference(account)
    transactions = self.get_subsequent_transactions(account)
    transactions.each do |transaction|
      if [DEBIT, CREDIT, SPLIT].include? transaction.ttype
        transaction.balance_before += amount
        transaction.balance_after += amount
      else
        transaction.o_balance_before += amount
        transaction.o_balance_after += amount
      end
      transaction.save!
    end
  end

  # def self.create(attributes)
  #   @transaction = Transaction.new(attributes)
  #   @transaction.save!
  #   return @transaction
  # end

  def get_balance_before(account=self.account)
    arr = account.transactions.where('date < ? OR (date = ? AND t_order < ?)', self.date, self.date, self.t_order).order([date: :desc, t_order: :desc]).limit(1)
    if arr.present?
      prev_tr = arr.first
      return prev_tr.balance_after, true
    else
      opening_tr = account.move_opening_transaction(self.date, self.get_difference(account))
      self.t_order = 2
      self.save!
      return opening_tr.balance_after, false
    end
  end

  def account_opening?
    self.meta.present? && self.meta['opening_transaction'] == true
  end

  def category
    Category.find_by_id(self.category_id)
  end

  def sub_category
    SubCategory.find_by_id(self.sub_category_id)
  end

  def create_split_transactions(tr_array)
    child_tr_ids = []
    tr_array.each do |tr_json|
      if tr_json['user']
        transaction = self.add_split_debit(tr_json)
      else
        transaction = self.add_split_paid_by_you(tr_json)
      end
      child_tr_ids << transaction&.id
    end
    self.meta["child_tr_ids"] = child_tr_ids
    self.save!
  end

  def delete_split_transactions
    return if self.ttype != SPLIT
    child_tr_ids = self.meta["child_tr_ids"]
    child_tr_ids.each do |tr_id|
      tr = Transaction.find_by_id(tr_id)
      tr.destroy
    end
  end

  def add_split_debit(args)
    meta = { "parent_tr_id" => self.id }
    transaction = Transaction.new(amount: args['amount'], ttype: DEBIT, date: self.date, category_id: self.category_id,
                                   pseudo: true, balance_before: self.balance_before, balance_after: self.balance_after,
                                   meta: meta, comments: self.comments, sub_category_id: self.sub_category_id,
                                   mop_id: self.mop_id, account_id: self.account_id, user_id: self.user_id, card_id: self.card_id)
    begin
      transaction.save!
      return transaction
    rescue StandardError => ex
      AdminMailer.error_mailer('add_split_debit', ex.message)
      puts "Error#add_split_debit: #{ex.message}"
    end
  end

  def add_split_paid_by_you(args)
    meta = { "parent_tr_id" => self.id }
    transaction = Transaction.new(amount: args['amount'], ttype: PAID_BY_YOU, date: self.date, party: args['party'],
                                  pseudo: true, meta: meta, comments: self.comments, mop_id: self.mop_id,
                                  account_id: self.account_id, user_id: self.user_id)
    begin
      transaction.save!
      owed_acc = self.user.accounts.find_by_id(args['party'])
      owed_acc.update_balance(transaction)
      # owed_acc.update_daily_log(transaction)
      balance_before, new_tr = transaction.get_balance_before(owed_acc)
      transaction.o_balance_before = balance_before
      transaction.o_balance_after = balance_before + transaction.get_difference(owed_acc)
      transaction.save!

      LazyWorker.perform_async("update_subsequent", {"transaction_id" => transaction.id}) if new_tr
      return transaction
    rescue StandardError => ex
      AdminMailer.error_mailer('add_split_paid_by_you', ex.message)
      puts "Error#add_split_paid_by_you: #{ex.message}"
    end
  end

  def transaction_box
    hash = self.attributes.slice('id', 'amount', 'ttype', 'party', 'category_id', 'pseudo', 'comments')
    hash['balance_before'] = Util.format_amount(self.balance_before, self.user)
    hash['balance_after'] = Util.format_amount(self.balance_after, self.user)
    hash['o_balance_before'] = Util.format_amount(self.o_balance_before, self.user)
    hash['o_balance_after'] = Util.format_amount(self.o_balance_after, self.user)
    formatted_amount = Util.format_amount(self.amount, self.user)
    # hash['formatted_amount'] = formatted_amount
    hash['date'] = self.date.strftime("%d-%m-%Y")

    if (self.user.configs['date_format'] == 1)
      hash['date_text'] = self.date.strftime("%d-%m-%Y")
    else
      hash['date_text'] = self.date.strftime('%d %b %Y')
    end

    if CREDIT_TRANSACTIONS.include? self.ttype
      hash['signed_amount'] = "+  ₹ #{formatted_amount}"
    else
      hash['signed_amount'] = "-  ₹ #{formatted_amount}"
    end
    hash['payment_symbol'] = self.payment_symbol
    hash['sub_category'] =  self.sub_category.name unless self.sub_category.nil?
    hash['comments_mob'] = hash['comments']
    hash['category'] = self.sub_category.sub_category_box unless self.sub_category.nil?
    hash['mop_name'] = self.mop&.processed_name
    if hash['comments'] and hash['comments'].length > 33
      hash['comments_mob'] = hash['comments'][..30] + '...'
    end
    hash
  end

  def payment_symbol
    if self.card_id.present?
      symbol = 'card'
      name = self.card.name
    elsif self.account.is_cash?
      symbol = 'cash'
      name = CASH_ACCOUNT
    else
      if self.account.owed
        symbol = 'party'
      else
        symbol = 'account'
      end
      name = self.account.name
    end
    {
      "symbol" => symbol,
      "name" => name
    }
  end

  def update_budgets
    category = self.category
    if category.present?
      month_code = category.budget['monthly'][Util.get_date_code_month(date)]
      unless month_code.present?
        category.budget['monthly'][Util.get_date_code_month(date)] = 0
      end
      category.budget['monthly'][Util.get_date_code_month(date)] += self.amount

      yealy_code = category.budget['yearly'][Util.get_date_code_year(date)]
      unless yealy_code.present?
        category.budget['yearly'][Util.get_date_code_year(date)] = 0
      end
      category.budget['yearly'][Util.get_date_code_year(date)] += self.amount
      category.save!
    end

    sub_category = self.sub_category
    if sub_category.present?
      month_code = sub_category.budget['monthly'][Util.get_date_code_month(date)]
      unless month_code.present?
        sub_category.budget['monthly'][Util.get_date_code_month(date)] = 0
      end
      sub_category.budget['monthly'][Util.get_date_code_month(date)] += self.amount

      yealy_code = sub_category.budget['yearly'][Util.get_date_code_year(date)]
      unless yealy_code.present?
        sub_category.budget['yearly'][Util.get_date_code_year(date)] = 0
      end
      sub_category.budget['yearly'][Util.get_date_code_year(date)] += self.amount
      sub_category.save!
    end
  end



  def self.validate_split(amount, tr_json)
    return
  end

  def self.analytics(list)
    json = {}
    json['labels'] = []
    data = []
    list.each do|hash|
      json['labels'] << hash['label']
      spent = 0
      hash['transactions'].each do |transaction|
        spent += transaction.amount
      end
      data << spent
    end
    json['labels'] = json['labels'].reverse
    json['datasets'] = [
      {
        'data' => data.reverse
      }
    ]
    json
  end

  def mop
    if self.mop_id.present?
      return Mop.find_by_id(self.mop_id)
    end
    return nil
  end

  private

  def self.find_previous_element(arr, element)
    index = arr.index(element)

    if index.nil? || index == 0
      nil  # Element not found or it's the first element
    else
      arr[index - 1]  # Return the previous element
    end
  end

end
