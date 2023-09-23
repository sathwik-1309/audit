class DailyLog < ApplicationRecord
  belongs_to :user
  belongs_to :account

  def add_transaction(transaction)
    self.total_transactions += 1
    self.closing_balance += transaction.get_difference
    self.meta['tr_ids'] += [transaction.id]
    self.save!
  end

end
