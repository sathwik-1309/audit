class AccountController < ApplicationController
  before_action :check_current_user

  def index
    accounts = Account.list(@current_user)
    render(:json => accounts)
  end

  def index_owed
    accounts = Account.list(@current_user, true)
    render(:json => accounts.to_json)
  end

  # def show_owed
  #   owed = @current_user.accounts.find_by_id(filter_params[:id])
  #   render(:json => owed.attributes)
  # end

  # required - name
  # optional - owed
  def create
    name = Util.processed_name(filter_params[:name])
    if @current_user.accounts.pluck(:name).include? name
      render_400("An account with the same name already exists") and return
    end
    attributes = {}
    attributes[:name] = name
    attributes[:user_id] = @current_user.id
    attributes[:balance] = filter_params[:balance]
    attributes[:opening_date] = filter_params[:date].present? ? filter_params[:date] : Date.today
    @account = Account.new(attributes)
    begin
      @account.save!
      msg = @account.attributes
      render_200("Account created", msg)
    rescue StandardError => ex
      render_400(ex.message)
    end
  end

  def create_owed
    name = Util.processed_name(filter_params[:name])
    if @current_user.accounts.pluck(:name).include? name
      render_400("An account with the same name already exists") and return
    end
    attributes = {}
    attributes[:name] = name
    attributes[:user_id] = @current_user.id
    attributes[:balance] = 0
    attributes[:opening_date] = Date.today - 365
    attributes[:owed] = true
    @account = Account.new(attributes)
    begin
      @account.save!
      msg = @account.attributes
      render_200("Owed Account created", msg)
    rescue StandardError => ex
      render_400(ex.message)
    end
  end

  # required - id(path)
  # optional - name, owed, balance
  def update
    @account = Account.find_by_id(params[:id])
    if @account.nil?
      render_404("Account not found") and return
    end
    @account.assign_attributes(filter_params)
    begin
      @account.save!
      msg = @account.attributes
      render_200("Account updated", msg)
    rescue StandardError => ex
      render_400(ex.message)
    end
  end

  # required - id(path)
  def delete
    @account = Account.find_by_id(params[:id])
    if @account.nil?
      render_404("Account not found") and return
    end
    begin
      @account.destroy
      msg = @account.attributes
      render_200("Account deleted", msg)
    rescue StandardError => ex
      render_400(ex.message)
    end
  end

  def home
    json = {
      "theme" => @current_user.theme,
      "username" => @current_user.name
    }
    render(:json => json)
  end

  def home_page
    json = {}
    @account = @current_user.accounts.find_by_id(filter_params[:id])
    categories = @current_user.categories
    json['pie_chart'] = @account.pie_chart_meta

    sub_category_json = {}
    categories.each do |category|
      sub_category_json["category_#{category.id}"] = @account.pie_chart_meta_sub_category(category)
    end
    json['pie_chart_sub_category'] = sub_category_json
    json['categories'] = categories.map{|c| { "id"=> c.id, "name"=> c.name}}
    render(:json => json)
  end

  def stats
    json = {}
    @account = @current_user.accounts.find_by_id(filter_params[:id])
    period = 'week'
    if params[:period].present? and PERIODS.include? params[:period]
      period = params[:period]
    end
    json['stats'] = @account.stats(period)
    json['account'] = @account.attributes
    render(:json => json)
  end

  def paginate_transactions
    page_number = filter_params[:page_number].to_i.positive? ? filter_params[:page_number].to_i : 1
    page_size = filter_params[:page_size].to_i
    @account = @current_user.accounts.find_by_id(filter_params[:id])
    transactions = @account.owed ? @account.owed_transactions : @account.transactions
    transactions = transactions.order(date: :desc).limit(page_size).offset(page_size*(page_number-1))
    json = []
    transactions.each do|transaction|
      json << transaction.transaction_box
    end
    render(:json => json)
  end

  private

  def filter_params
    params.permit(:name, :id, :owed, :balance, :date, :page_number, :page_size)
  end

end
