class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :account

  before_save :validate_transaction
  after_create :track_modifications


  def validate_transaction
    raise StandardError.new("Cannot add a transaction in past date of account opening") if self.account.opening_date > self.date
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
    prev_tr = self.get_previous
    self.balance_before = prev_tr.balance_after
    self.balance_after = prev_tr.balance_after + self.get_difference(self.account)
    self.save!
    if [DEBIT, PAID_BY_PARTY].include? self.ttype
      self.update_budgets
    end
    LazyWorker.perform_async("update_subsequent", {"transaction_id" => self.id})
    if [PAID_BY_YOU, SETTLED_BY_PARTY, SETTLED_BY_YOU].include? self.ttype
      owed_acc = Account.find_by_id(self.party)
      owed_acc.update_balance(self)
      # owed_acc.update_daily_log(self)
      LazyWorker.perform_async("update_subsequent", {"transaction_id" => self.id, "account_id"=> owed_acc.id})
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
    prev_tr = self.get_previous
    self.t_order = prev_tr.t_order + 1
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

  def get_subsequent_transactions(account=self.acccount)
    account.transactions.where('date > ? OR (date = ? AND t_order > ?)', self.date, self.date, self.t_order)
  end

  def update_subsequent(account=self.account)
    amount = self.get_difference(account)
    transactions = self.get_subsequent_transactions(account)
    transactions.each do |transaction|
      transaction.balance_before += amount
      transaction.balance_after += amount
      transaction.save!
    end
  end

  # def self.create(attributes)
  #   @transaction = Transaction.new(attributes)
  #   @transaction.save!
  #   return @transaction
  # end

  def get_previous(account=self.account)
    arr = account.transactions.where('date < ? OR (date = ? AND t_order < ?)', self.date, self.date, self.t_order).order(date: :desc, t_order: :desc)
    if arr.present?
      prev_tr = arr.first
    else 
      raise StandardError.new("Previous Transaction not found")
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
      prev_tr = transaction.get_previous(owed_acc)
      transaction.balance_before = prev_tr.balance_after
      transaction.balance_after = prev_tr.balance_after + transaction.get_difference(owed_acc)
      transaction.save!
      LazyWorker.perform_async("update_subsequent", {"transaction_id" => transaction.id})
      return transaction
    rescue StandardError => ex
      AdminMailer.error_mailer('add_split_paid_by_you', ex.message)
      puts "Error#add_split_paid_by_you: #{ex.message}"
    end
  end

  def transaction_box
    hash = self.attributes.slice('id', 'amount', 'ttype', 'date', 'party', 'category_id', 'pseudo', 'balance_after', 'balance_before', 'comments')
    if CREDIT_TRANSACTIONS.include? self.ttype
      hash['signed_amount'] = "+  ₹ #{self.amount}"
    else
      hash['signed_amount'] = "-  ₹ #{self.amount}"
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
      symbol = 'account'
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
