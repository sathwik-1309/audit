class Card < ApplicationRecord
  belongs_to :user
  belongs_to :account

  after_create :after_create_action
  after_commit :after_save_action, on: [:create, :update]
  after_destroy :after_delete_action

  def after_create_action
    Mop.create("#{self.ctype}_#{self.name}", self.account, {"ctype" => self.ctype, "card_id"=>self.id })
  end

  def after_delete_action
    Websocket.publish(CARDS_CHANNEL, 'refresh')
  end

  def after_save_action
    Websocket.publish(CARDS_CHANNEL, 'refresh')
  end

  def mop
    self.account.mops.find{|m| self.id == m.meta["card_id"]}
  end

  def update_outstanding_bill(amount)
    self.outstanding_bill += amount.to_f
    self.save!
  end

end
