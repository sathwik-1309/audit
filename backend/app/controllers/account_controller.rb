class AccountController < ApplicationController
  before_action :check_current_user

  def index
    json = {}
    json['accounts'] = Account.list(@current_user)
    json['lock'] = @current_user.configs['lock']
    render(:json => Oj.dump(json))
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
    # begin
      @account.destroy
      msg = @account.attributes
      render_200("Account deleted", msg)
    # rescue StandardError => ex
    #   render_202(ex.message)
    # end
  end

  def home
    json = {
      "theme" => @current_user.theme,
      "username" => @current_user.name,
      "app_theme" => @current_user.app_theme
    }
    render_200("Successfull", json)
  end

  def home_page
    start_date = DateTime.parse(filter_params[:start_date]).strftime("%Y-%m-%d")
    end_date = DateTime.parse(filter_params[:end_date]).strftime("%Y-%m-%d")
    json = {}
    @account = @current_user.accounts.find_by_id(filter_params[:id])
    categories = @current_user.categories
    json['pie_chart'] = @account.pie_chart_meta(start_date, end_date)

    sub_category_json = {}
    categories.each do |category|
      sub_category_json["category_#{category.id}"] = @account.pie_chart_meta_sub_category(category)
    end
    json['pie_chart_sub_category'] = sub_category_json
    json['categories'] = categories.map{|c| { "id"=> c.id, "name"=> c.name}}
    render(:json => json)
  end

  def stats
    start_date = DateTime.parse(filter_params[:start_date]).strftime("%Y-%m-%d")
    end_date = DateTime.parse(filter_params[:end_date]).strftime("%Y-%m-%d")
    json = {}
    @account = @current_user.accounts.find_by_id(filter_params[:id])
    json['stats'] = @account.stats(start_date, end_date)
    json['account'] = @account.attributes
    render(:json => json)
  end

  def paginate_transactions
    start_date = DateTime.parse(filter_params[:start_date]).strftime("%Y-%m-%d")
    end_date = DateTime.parse(filter_params[:end_date]).strftime("%Y-%m-%d")
    page_number = filter_params[:page_number].to_i.positive? ? filter_params[:page_number].to_i : 1
    page_size = filter_params[:page_size].to_i
    @account = @current_user.accounts.find_by_id(filter_params[:id])
    transactions = @account.owed ? @account.owed_transactions : @account.transactions
    transactions = transactions.order(date: :desc).where("date BETWEEN ? AND ?", start_date, end_date).limit(page_size).offset(page_size*(page_number-1))
    json = []
    transactions.each do|transaction|
      json << transaction.transaction_box
    end
    render(:json => json)
  end

  private

  def filter_params
    params.permit(:name, :id, :owed, :balance, :date, :page_number, :page_size, :start_date, :end_date)
  end

end
