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

  def get_budget(type)
    temp = {}
    if type == 'monthly'
      spent = self.budget[type][Util.get_date_code_month(Date.today)]
    else
      spent = self.budget[type][Util.get_date_code_year(Date.today)]
    end
    temp = {
      "spent" => spent.present? ? spent : 0,
      "formatted_spent" => spent.present? ? Util.format_amount(spent, self.user) : 0,
      "budget" => type == 'monthly' ? self.monthly_limit : self.yearly_limit,
      "formatted_budget" => type == 'monthly' ? Util.format_amount(self.monthly_limit, self.user) : Util.format_amount(self.yearly_limit, self.user)
    }
    if temp['budget'].present?
      temp['percentage'] = (temp['spent']*100/temp['budget']).to_i
    else
      temp['percentage'] = 0
    end
    temp
  end
end