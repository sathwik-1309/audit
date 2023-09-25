class Category < ApplicationRecord
  belongs_to :user
  has_many :sub_categories

  after_commit :after_save_action, on: [:create, :update]
  after_destroy :after_delete_action

  def after_save_action
    Websocket.publish(CATEGORY_CHANNEL, 'refresh')
  end

  def after_delete_action
    Websocket.publish(CATEGORY_CHANNEL, 'refresh')
  end

end