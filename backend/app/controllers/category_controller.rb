class CategoryController < ApplicationController
  before_action :check_current_user

  def index
    json = {}
    arr = []
    categories = @current_user.categories
    categories.each do |category|
      temp = category.attributes.slice('id', 'name', 'color')
      sub_categories = []
      category.sub_categories.each do |sub_category|
        sub_categories << sub_category.attributes.slice('id', 'name', 'color')
      end
      temp['sub_categories'] = sub_categories
      temp['sub_category_count'] = sub_categories.length
      temp['monthly'] = category.get_budget('monthly')
      temp['yearly'] = category.get_budget('yearly')
      
      arr << temp
    end
    json['categories'] = arr
    json['colors'] = CATEGORY_COLORS
    render(:json => Oj.dump(json))
  end

  def create
    name = filter_params[:name].downcase
    if @current_user.categories.pluck(:name).include? name
      render_202("Category already exists") and return
    end
    attributes = filter_params.slice(:name, :color)
    attributes[:user_id] = @current_user.id
    if filter_params[:monthly_limit].present?
      attributes[:monthly_limit] = filter_params[:monthly_limit]
      attributes[:yearly_limit] = ((filter_params[:monthly_limit].to_f)*12).to_i
    end
    attributes[:budget] = BUGDET_INIT
    @category = Category.new(attributes)
    begin
      @category.save!
      msg = @category.attributes
      render_200("Category created", msg)
    rescue StandardError => ex
      render_400(ex.message)
    end
  end

  def delete
    @category = @current_user.categories.find_by_id(params[:id])
    if @category.nil?
      render_202("Category not found") and return
    end
    begin
      @category.destroy
      msg = @category.attributes
      render_200("Category deleted", msg)
    rescue StandardError => ex
      render_400(ex.message)
    end
  end

  private

  def filter_params
    params.permit(:name, :monthly_limit, :color)
  end
end