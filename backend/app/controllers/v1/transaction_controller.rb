class V1::TransactionController < ApplicationController
  before_action :check_current_user

  def list
    if filter_params[:account_id].present?
      account = @current_user.accounts.find_by_id(filter_params[:account_id])
      if account.nil?
        render_202("Account not found") and return
      end
      transactions = account.transactions.where(pseudo: false)
    else
      transactions = @current_user.transactions
    end

    start_date, end_date = nil, nil
    if filter_params[:start_date].present?
      start_date = DateTime.parse(filter_params[:start_date]).strftime("%Y-%m-%d")
      end_date = DateTime.parse(filter_params[:end_date]).strftime("%Y-%m-%d")
    elsif filter_params[:month].present?
      start_date, end_date = Util.month_year_to_start_end_date(filter_params[:month], filter_params[:year])
    end
    
    if start_date.present?
      transactions = transactions.where("date BETWEEN ? AND ?", start_date, end_date)
    end
    arr = []
    transactions.each do|transaction|
      arr << transaction.transaction_box
    end
    render(:json => arr)
  end

  private

  def filter_params
    params.permit(:account_id, :start_date, :end_date, :month, :year)
  end

end