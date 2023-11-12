class V1::UserController < ApplicationController
  before_action :set_current_user

  def home
    if @current_user.nil?
      render_202("User not authorized")
    end
    json = {}
    json['accounts'] = Account.list(@current_user)
    json['parties'] = Account.list(@current_user, true)
    json['sub_categories'] = @current_user.sub_categories.map{|s| s.attributes.slice('id', 'name')}
    json['cards'] = @current_user.cards.map{|card| card.attributes.slice('id', 'name', 'ctype')}
    render(:json => Oj.dump(json))
  end

  def configs
    if @current_user.nil?
      render_202("User not authorized")
    end
    json = @current_user.configs
    render(:json => Oj.dump(json))
  end

  def update_configs
    if @current_user.nil?
      render_202("User not authorized")
    end
    configs = @current_user.configs 
    if filter_params[:amount_decimal].present?
      configs['amount_decimal'] = filter_params[:amount_decimal] == 'enabled' ? true : false
    elsif filter_params[:amount_commas].present?
      configs['amount_commas'] = filter_params[:amount_commas] == 'enabled' ? true : false
    end
    
    @current_user.configs = configs
    
    begin
      @current_user.save!
      render_200("User Updated")
    rescue StandardError => ex
      render_202(ex.message)
    end
    


  end

  private

  def filter_params
    params.permit(:amount_commas, :amount_decimal)
  end

end