class Account < ApplicationRecord
  belongs_to :user
  has_many :transactions
  has_many :daily_logs

  def add_opening_balance(amount, mop)
    status, tr = Transaction.credit(amount, Date.today, mop, self, {}, "opening transaction")
    return status, tr unless status
    self.update_balance(CREDIT, amount)
    self.update_daily_log(tr)
  end

  def update_balance(type, amount)
    if type == CREDIT
      self.balance = self.balance + amount
    else
      self.balance = self.balance - amount
    end
    self.save!
  end

  def update_daily_log(transaction)
    log = self.daily_logs.where(date: transaction.date)
    if log.blank?
      if self.daily_logs.blank?
        meta = {"tr_ids" => [transaction.id]}
        log = DailyLog.new(opening_balance: 0, closing_balance: 0, account_id: transaction.account_id, user_id: transaction.user_id, meta: meta, date: transaction.date, total_transactions: 0)
        log.save!
      else
        opening_balance = self.daily_logs.last.closing_balance
        log = DailyLog.new(opening_balance: opening_balance, closing_balance: opening_balance, account_id: transaction.account_id, user_id: transaction.user_id, meta: meta, date: transaction.date, total_transactions: 0)
        log.save!
      end
    end
    log.update(transaction)
  end
end
