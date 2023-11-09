class Mop < ApplicationRecord
  belongs_to :user
  belongs_to :account

  after_commit :after_save_action, on: [:create, :update]
  after_destroy :after_delete_action

  def after_delete_action
    Websocket.publish(MOPS_CHANNEL, 'refresh')
  end

  def after_save_action
    Websocket.publish(MOPS_CHANNEL, 'refresh')
  end

  def self.create(name, account, meta = {} )
    mop = Mop.new(name: name, account_id: account.id, user_id: account.user_id, meta: meta)
    mop.save!
    return mop
  end

  def processed_name
    return "Account" if self.is_auto_generated?
    return "Card" if self.is_card?
    self.name
  end

  # def is_auto_generated?
  #   return true if self.meta["auto_generated"] and  self.meta["auto_generated"] == true
  #   return false
  # end

  # def is_card?
  #   return true if self.meta["ctype"] and self.meta["card_id"]
  #   return false 
  # end
end
