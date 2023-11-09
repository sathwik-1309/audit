class V1::TransactionController < ApplicationController
  before_action :check_current_user

  def list
    if filter_params[:account_id].present?
      account = @current_user.accounts.find_by_id(filter_params[:account_id])
      if account.nil?
        render_202("Account not found") and return
      end
      transactions = account.transactions
    elsif filter_params[:card_id].present?
      transactions = @current_user.transactions.where(card_id: filter_params[:card_id])
    elsif filter_params[:category_id].present?
      transactions = @current_user.transactions.where(category_id: filter_params[:category_id])
    elsif filter_params[:sub_category_id].present?
      transactions = @current_user.transactions.where(sub_category_id: filter_params[:sub_category_id])
    else
      transactions = @current_user.transactions
    end

    if filter_params[:party].present?
      transactions = transactions.where(party: filter_params[:party])
    else
      transactions = transactions.where(pseudo: false)
    end

    transactions = transactions.where.not(comments: 'account opening transaction')
    

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
      if account.nil?
        render_202("Account not found") and return
      end
      transactions = account.transactions
    elsif filter_params[:card_id].present?
      transactions = @current_user.transactions.where(card_id: filter_params[:card_id])
    elsif filter_params[:category_id].present?
      transactions = @current_user.transactions.where(category_id: filter_params[:category_id])
    elsif filter_params[:sub_category_id].present?
      transactions = @current_user.transactions.where(sub_category_id: filter_params[:sub_category_id])
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

  def pie
    sub_cat = false
    start_date, end_date = nil, nil
    if filter_params[:start_date].present?
      start_date = DateTime.parse(filter_params[:start_date]).strftime("%Y-%m-%d")
      end_date = DateTime.parse(filter_params[:end_date]).strftime("%Y-%m-%d")
    elsif filter_params[:month].present?
      start_date, end_date = Util.month_year_to_start_end_date(filter_params[:month], filter_params[:year])
    end

    if filter_params[:account_id].present?
      account = @current_user.accounts.find_by_id(filter_params[:account_id])
      if account.nil?
        render_202("Account not found with this ID") and return
      end
      transactions = account.transactions
    elsif filter_params[:card_id].present?
      transactions = @current_user.transactions.where(card_id: filter_params[:card_id])
    elsif filter_params[:category_id].present?
      sub_cat = true
      transactions = @current_user.transactions.where(category_id: filter_params[:category_id])
    else
      transactions = @current_user.transactions
    end

    if start_date.present?
      transactions = transactions.where("date BETWEEN ? AND ?", start_date, end_date)
    end

    transactions = transactions.where(ttype: [DEBIT, PAID_BY_PARTY])
    
    json = []
    dict = {}
    total_spent = 0
    if sub_cat
      transactions.each do|transaction|
        sub_category = transaction.sub_category
        name = sub_category.nil? ? "other" : sub_category.name
        color = sub_category.category.nil? ? 'gray' : sub_category.category.color
        unless dict.has_key? name
          dict[name] = Util.init_pie_category(name, color)
        end
        dict[name]['transactions'] << transaction
        dict[name]['expenditure'] += transaction.amount
        total_spent += transaction.amount
      end
    else
      transactions.each do|transaction|
        category = transaction.category
        name = category.nil? ? "other" : category.name
        color = category.nil? ? 'gray' : category.color
        unless dict.has_key? name
          dict[name] = Util.init_pie_category(name, color)
        end
        dict[name]['transactions'] << transaction
        dict[name]['expenditure'] += transaction.amount
        total_spent += transaction.amount
      end
    end
    
    i = 0
    dict.keys.each do|key|
      dict[key]['percentage'] = (dict[key]['expenditure']*100/total_spent).round(0)
      if sub_cat
        dict[key]['color'] = CATEGORY_COLORS[i]['color']
      end
      i += 1
    end
    render(:json => dict.values)
  end

  private

  def filter_params
    params.permit(:account_id, :card_id, :party, :start_date, :end_date, :month, :year, :category_id, :sub_category_id)
  end

end