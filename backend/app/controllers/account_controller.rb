class AccountController < ApplicationController
  before_action :check_current_user
  def index
    accounts = current_user.accounts
    render(:json => accounts.to_json)
  end

  def create
    attributes = filter_params.slice(:name, :owed)
    attributes[:user_id] = current_user.id
    attributes[:balance] = 0
    @account = Account.new(attributes)
    if @account.save!
      status, mop = Mop.create("initial transfer", @account)
      status, error = @account.add_opening_balance(filter_params[:balance], mop)
      msg = @account.attributes
      if status
        render_200("Account created", msg)
      else
        render_404(error)
      end
    else
      render_404("Some error occured")
    end
  end

  def update
    @account = Account.find_by_id(params[:id])
    if @account.nil?
      render_404("Account not found") and return
    end
    @account.assign_attributes(filter_params)
    if @account.save!
      msg = @account.attributes
      render_200("Account updated", msg)
    else
      render_404("Some error occured")
    end
  end

  def delete
    @account = Account.find_by_id(params[:id])
    if @account.nil?
      render_404("Account not found") and return
    end
    @account.delete
    msg = @account.attributes
    render_200("Account deleted", msg)
  end

  private

  def filter_params
    params.permit(:name, :id, :owed, :balance, :opening_balance)
  end

end
