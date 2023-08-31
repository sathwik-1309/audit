class Mop < ApplicationRecord
  belongs_to :user
  belongs_to :account

  def self.create(name, account)
    mop = Mop.new(name: name, account_id: account.id, user_id: account.user_id)
    if mop.save!
      return true, mop
    else
      return false, mop.errors.full_messages
    end
  end
end
