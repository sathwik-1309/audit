class V1::AccountController < ApplicationController
  before_action :check_current_user

  def details
    json = {}
    account = @current_user.accounts.find_by_id(params[:id])
    if account.nil?
      render_202("Account not found") and return
    end
    json['details'] = account.attributes.slice('id', 'name', 'balance')

    start_date = filter_params[:start_date].present? ? DateTime.parse(filter_params[:start_date]).strftime("%Y-%m-%d") : nil
    end_date = filter_params[:end_date].present? ? DateTime.parse(filter_params[:end_date]).strftime("%Y-%m-%d") : nil
    
    json['stats'] = account.stats(start_date, end_date)
    json['mops'] = account.mops.filter{|mop| !mop.meta['card_id'].present? }.map{|mop| mop.attributes.slice('id', 'name')}
    render(:json => Oj.dump(json))
  end

  private

  def filter_params
    params.permit(:id, :start_date, :end_date, :month, :year)
  end
end