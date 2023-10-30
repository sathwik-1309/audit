class SubCategory < ApplicationRecord
  belongs_to :user
  belongs_to :category

  after_commit :after_save_action, on: [:create, :update]
  after_destroy :after_delete_action

  def after_save_action
    Websocket.publish(CATEGORY_CHANNEL, 'refresh')
  end

  def after_delete_action
    Websocket.publish(CATEGORY_CHANNEL, 'refresh')
  end

  def sub_category_box
    hash = {
      'id' => self.id,
      'category' => self.category.name,
      'sub_category' => self.name,
      'category_id' => self.category.id,
      'color' => self.category.color,
    }
  end
end