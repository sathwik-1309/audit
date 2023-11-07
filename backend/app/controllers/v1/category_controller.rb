class V1::CategoryController < ApplicationController
  before_action :check_current_user

  def details
    json = {}
    category = @current_user.categories.find_by_id(params[:id])
    if category.nil?
      render_202("Category not found") and return
    end
    details = category.attributes.slice('id', 'name', 'color', 'monthly_limit', 'yearly_limit')
    details['color'] = CATEGORY_COLORS.select{|color| color['color'] == category.color}.first
    json['details'] = details
    
    json['monthly'] = category.get_budget('monthly')
    json['yearly'] = category.get_budget('yearly')

    json['colors'] = CATEGORY_COLORS
    render(:json => Oj.dump(json))
  end

  def sub_categories
    category = @current_user.categories.find_by_id(params[:id])
    if category.nil?
      render_202("Category not found") and return
    end
    sub_categories = []
    category.sub_categories.each do |sub_cat|
      temp = sub_cat.attributes.slice('id', 'name', 'color', 'monthly_limit', 'yearly_limit')
      temp['monthly'] = sub_cat.get_budget('monthly')
      temp['yearly'] = sub_cat.get_budget('yearly')
      temp['color'] = sub_cat.category.color
      sub_categories << temp
    end
    render(:json => Oj.dump(sub_categories))
  end
end