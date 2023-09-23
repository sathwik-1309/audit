class MopController < ApplicationController
  before_action :check_current_user

  def index
    json = []
    mops = @current_user.mops
    mops = mops.select{|m| !m.is_card? and !m.is_auto_generated?} if params[:unfiltered].nil?
    mops.each do |mop|
      temp = mop.attributes
      temp['account'] = {
        "name" => mop.account.name
      }
      json << temp
    end
    render(:json => json)
  end

  def create
    attributes = filter_params.slice(:account_id, :name)
    attributes[:user_id] = @current_user.id
    @mop = Mop.new(attributes)
    begin
      @mop.save!
      msg = @mop.attributes
      render_200("Mode of payment created", msg)
    rescue StandardError => ex
      render_400(ex.message)
    end
  end

  def update
    @mop = Mop.find_by_id(params[:id])
    if @mop.nil?
      render_404("Mode of payment not found") and return
    end
    @mop.assign_attributes(filter_params)
    if @mop.save!
      msg = @mop.attributes
      render_200("Mode of payment updated", msg)
    else
      render_404("Some error occured")
    end
  end

  def delete
    @mop = Mop.find_by_id(params[:id])
    if @mop.nil?
      render_404("Mode of payment not found") and return
    end
    @mop.destroy
    msg = @mop.attributes
    render_200("Mode of payment deleted", msg)
  end

  private

  def filter_params
    params.permit(:account_id, :name)
  end

end
