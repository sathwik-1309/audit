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

  def monthly_budget
    temp = {}
    monthly_spent = self.budget['monthly'][Util.get_date_code_month(Date.today)]
    temp['monthly'] = {
      "spent" => monthly_spent.present? ? monthly_spent : 0,
      "budget" => self.monthly_limit
    }
    if temp['monthly']['budget'].present?
      temp['monthly']['percentage'] = (temp['monthly']['spent']*100/temp['monthly']['budget']).to_i
    else
      temp['monthly']['percentage'] = 0
    end
    temp
  end

  def yearly_budget
    temp = {}
    yearly_spent = self.budget['yearly'][Util.get_date_code_year(Date.today)]
    temp['yearly'] = {
      "spent" => yearly_spent.present? ? yearly_spent : 0,
      "budget" => self.yearly_limit
    }
    if temp['yearly']['budget'].present?
      temp['yearly']['percentage'] = (temp['yearly']['spent']*100/temp['yearly']['budget']).to_i
    else
      temp['yearly']['percentage'] = 0
    end
    temp
  end
end