class SubCategoryController < ApplicationController
  before_action :check_current_user

  def index
    sub_categories = @current_user.sub_categories
    render(:json => sub_categories.to_json)
  end

  def create
    name = Util.processed_name(filter_params[:name])
    if filter_params[:category_id].present?
      category = @current_user.categories.find_by_id(filter_params[:category_id])
    elsif filter_params[:force]
      category = Category.new(name: filter_params[:name], user_id: @current_user.id, color: filter_params[:color])
      begin
        category.save!
      rescue StandardError => ex
        render_202(ex.message) and return
      end
    end
    
    if category.nil?
      render_202("Invalid Category") and return
    end
    if category.sub_categories.pluck(:name).include? name
      render_202("Sub-category #{name} already exists in this category") and return
    end
    attributes = {}
    attributes[:category_id] = category.id
    attributes[:user_id] = @current_user.id
    attributes[:name] = name
    @sub_category = SubCategory.new(attributes)
    begin
      @sub_category.save!
      msg = @sub_category.attributes
      render_200("Sub-category created", msg)
    rescue StandardError => ex
      render_400(ex.message)
    end
  end

  def delete
    @sub_category = @current_user.sub_categories.find_by_id(params[:id])
    if @sub_category.nil?
      render_202("Sub-category not found") and return
    end
    begin
      @sub_category.destroy
      msg = @sub_category.attributes
      render_200("Sub-category deleted", msg)
    rescue StandardError => ex
      render_400(ex.message)
    end
  end

  private

  def filter_params
    params.permit(:name, :category_id, :force, :color)
  end
end