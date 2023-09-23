class Card < ApplicationRecord
  belongs_to :user
  belongs_to :account

  after_commit :after_save_action, on: [:create, :update]
  after_destroy :after_delete_action

  def after_delete_action
    Websocket.publish(CARDS_CHANNEL, 'refresh')
  end

  def after_save_action
    Websocket.publish(CARDS_CHANNEL, 'refresh')
  end

  def mop
    self.account.mops.find{|m| m.meta["card_id"] and self.id.to_s == m.meta["card_id"]}
  end

end
