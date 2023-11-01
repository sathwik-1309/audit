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

  def analytics
    json = {}
    if filter_params[:account_id].present?
      account = @current_user.accounts.find_by_id(filter_params[:account_id])
      transactions = account.transactions
    else
      transactions = @current_user.transactions
    end
    transactions = transactions.where(ttype: [DEBIT, PAID_BY_PARTY])

    tr_list = []
    date = Date.today
    i = 0
    while (i < 7)
      temp = {
        'label' => (date-i).strftime('%b %d'),
        'transactions' => transactions.where(date: date - i)
      }
      tr_list << temp
      i+=1
    end
    json['last_7_days'] = Transaction.analytics(tr_list)
    
    tr_list = []
    start_of_week = date.at_beginning_of_week
    end_of_week = date.at_end_of_week
    i = 0
    dict = {}
    while (i < 6)
      month_index = start_of_week.month
      dict[month_index] = 0 unless dict.has_key? month_index
      dict[month_index] += 1
      temp = {
        'label' => "#{start_of_week.strftime('%b %d')}",
        'transactions' => transactions.where(date: start_of_week..end_of_week)
      }
      tr_list << temp
      start_of_week = start_of_week-7
      end_of_week = end_of_week-7
      i+=1
    end
    json['last_6_weeks'] = Transaction.analytics(tr_list)

    tr_list = []
    start_of_month = date.at_beginning_of_month
    end_of_month = date.at_end_of_month
    i = 0
    while (i < 6)
      temp = {
        'label' => "#{MONTHS[start_of_month.month-1]}",
        'transactions' => transactions.where(date: start_of_month..end_of_month)
      }
      tr_list << temp
      start_of_month = start_of_month - 1.month
      end_of_month = end_of_month - 1.month
      i+=1
    end
    json['last_6_months'] = Transaction.analytics(tr_list)

    render(:json => Oj.dump(json))
  end

  private

  def filter_params
    params.permit(:account_id, :start_date, :end_date, :month, :year)
  end

end