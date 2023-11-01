class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :account
  belongs_to :mop

  before_save :validate_transaction
  after_create :track_modifications


  def validate_transaction
    raise StandardError.new("Cannot add a transaction in past date of account opening") if self.account.opening_date > self.date
  end

  def track_modifications
    return if self.pseudo
    return if self.account_opening?
    self.reload.account.update_balance(self)
    self.account.update_daily_log(self)
    prev_tr = self.get_previous
    self.balance_before = prev_tr.balance_after
    self.balance_after = prev_tr.balance_after + self.get_difference(self.account)
    self.save!
    LazyWorker.perform_async("update_subsequent", {"transaction_id" => self.id})
    if [PAID_BY_YOU, SETTLED_BY_PARTY, SETTLED_BY_YOU].include? self.ttype
      owed_acc = Account.find_by_id(self.party)
      owed_acc.update_balance(self)
      owed_acc.update_daily_log(self)
      LazyWorker.perform_async("update_subsequent", {"transaction_id" => self.id, "account_id"=> owed_acc.id})
    end
  end

  def self.account_opening(amount, mop, date, account)
    tr = Transaction.new(amount: amount, ttype: CREDIT, date: date, user: account.user, account: account,
                         meta: { "opening_transaction" => true }, comments: "account opening transaction",
                         mop: mop, balance_before: 0, balance_after: amount)
    tr.save!
    return tr
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

  def update_subsequent(account=self.account)
    amount = self.get_difference(account)
    daily_logs = account.daily_logs.where("date > ?",self.date)
    daily_logs.each do |daily_log|
      daily_log.opening_balance += amount
      daily_log.closing_balance += amount
      daily_log.save!
      transactions = self.user.transactions.where(id: daily_log.meta['tr_ids'])
      transactions.each do |transaction|
        transaction.balance_before += amount
        transaction.balance_after += amount
        transaction.save!
      end
    end
  end

  # def self.create(attributes)
  #   @transaction = Transaction.new(attributes)
  #   @transaction.save!
  #   return @transaction
  # end

  def get_previous(account=self.account)
    daily_log = account.daily_logs.find_by(date: self.date)
    prev_tr = Transaction.find_by_id(Transaction.find_previous_element(daily_log.meta['tr_ids'], self.id))
    if prev_tr.nil?
      prev_daily_log = account.daily_logs.where("date < ?", self.date).order(date: :desc).first
      raise StandardError.new("Cant find previous transaction for tr_id #{self.id}") if prev_daily_log.nil?
      prev_tr = Transaction.find_by_id(prev_daily_log.meta['tr_ids'][-1])
    end
    prev_tr
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
                                   mop_id: self.mop_id, account_id: self.account_id, user_id: self.user_id)
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
      owed_acc.update_daily_log(transaction)
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
    hash = self.attributes
    if CREDIT_TRANSACTIONS.include? self.ttype
      hash['signed_amount'] = "+  ₹ #{self.amount}"
    else
      hash['signed_amount'] = "-  ₹ #{self.amount}"
    end
    hash['sub_category'] =  self.sub_category.name unless self.sub_category.nil?
    hash['comments_mob'] = hash['comments']
    hash['category'] = self.sub_category.sub_category_box unless self.sub_category.nil?
    hash['mop_name'] = self.mop&.processed_name
    if hash['comments'] and hash['comments'].length > 33
      hash['comments_mob'] = hash['comments'][..30] + '...'
    end
    hash
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
