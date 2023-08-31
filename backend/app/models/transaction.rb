class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :account
  belongs_to :mop

  def self.credit(amount, date, mop, account, meta={}, comments="")
    tr = Transaction.new
    tr.amount = amount
    tr.ttype = CREDIT
    tr.date = date
    tr.user_id = account.user_id
    tr.account_id = account.id
    tr.balance_before = account.balance
    tr.balance_after =  account.balance + amount
    tr.meta = meta
    tr.comments = comments
    tr.mop_id = mop.id
    if tr.save!
      return true, tr
    else
      return false, tr.errors.full_messages
    end
  end

  def get_difference
    if CREDIT_TRANSACTIONS.include? self.ttype
      return self.amount
    else
      return -self.amount
    end
  end

end
