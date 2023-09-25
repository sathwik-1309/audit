class CategoryController < ApplicationController
  before_action :check_current_user

  def index
    categories = @current_user.categories
    render(:json => categories.to_json)
  end

  def create
    name = filter_params[:name].downcase
    if @current_user.categories.pluck(:name).include? name
      render_202("Category already exists") and return
    end
    attributes = filter_params.slice(:name)
    attributes[:user_id] = @current_user.id
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
    params.permit(:name)
  end
end