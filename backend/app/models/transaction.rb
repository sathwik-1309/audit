class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :account
  belongs_to :mop

  before_save :validate_transaction
  after_create :track_modifcations


  def validate_transaction
    raise StandardError.new("Cannot add a transaction in past date of account opening") if self.account.opening_date > self.date
  end

  def track_modifcations
    return if self.account_opening?
    self.reload.account.update_balance(self)
    self.account.update_daily_log(self)
    prev_tr = self.get_previous
    self.balance_before = prev_tr.balance_after
    self.balance_after = prev_tr.balance_after + self.get_difference
    self.save!
    LazyWorker.perform_async("update_subsequent", {"transaction_id" => self.id})
  end

  def self.account_opening(amount, mop, date, account)
    tr = Transaction.new(amount: amount, ttype: CREDIT, date: date, user: account.user, account: account,
                         meta: { "opening_transaction" => true }, comments: "account opening transaction",
                         mop: mop, balance_before: 0, balance_after: amount)
    tr.save!
    return tr
  end

  def get_difference
    if CREDIT_TRANSACTIONS.include? self.ttype
      return self.amount
    else
      return -self.amount
    end
  end

  def update_subsequent
    amount = self.get_difference
    daily_logs = DailyLog.where("date > ?",self.date)
    daily_logs.each do |daily_log|
      daily_log.opening_balance += amount
      daily_log.closing_balance += amount
      daily_log.save!
      transactions = Transaction.where(id: daily_log.meta['tr_ids'])
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

  def get_previous
    daily_log = DailyLog.find_by(date: self.date)
    prev_tr = Transaction.find_by_id(Transaction.find_previous_element(daily_log.meta['tr_ids'], self.id))
    if prev_tr.nil?
      prev_daily_log = DailyLog.where("date < ?", self.date).order(date: :desc).first
      raise StandardError.new("Cant find previous transaction for tr_id #{self.id}") if prev_daily_log.nil?
      prev_tr = Transaction.find_by_id(prev_daily_log.meta['tr_ids'][-1])
    end
    prev_tr
  end

  def account_opening?
    self.meta.present? && self.meta['opening_transaction'] == true
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
