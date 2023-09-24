class AccountController < ApplicationController
  before_action :check_current_user

  def index
    accounts = Account.list(@current_user)
    render(:json => accounts.to_json)
  end

  # required - name
  # optional - owed
  def create
    if @current_user.accounts.pluck(:name).include? filter_params[:name]
      render_400("An account with the same name already exists") and return
    end
    attributes = filter_params.slice(:name)
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
    if @current_user.accounts.pluck(:name).include? filter_params[:name]
      render_400("An account with the same name already exists") and return
    end
    attributes = filter_params.slice(:name)
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
      "username" => @current_user.name.titleize
    }
    render(:json => json)
  end

  private

  def filter_params
    params.permit(:name, :id, :owed, :balance, :date)
  end

end
