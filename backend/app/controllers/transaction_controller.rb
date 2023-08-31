class TransactionController < ApplicationController
  before_action :check_current_user

  def index
    if params[:account_id].present?
      @account = current_user.accounts.find_by_id(filter_params[:account_id])
      @transactions = @account.transactions
    else
      @transactions = current_user.transactions
    end
    render(:json => @transactions.to_json)
  end
  def create
    attributes = filter_params.slice(:account_id, :mop_id, :amount, :ttype, :date, :party, :category, :meta, :comments)
    attributes[:user_id] = current_user.id
    @transaction = Transaction.new(attributes)
    if @transaction.save!
      msg = @transaction.attributes
      render_200("Transaction created", msg)
    else
      render_404("Some error occured")
    end
  end

  def update
    @transaction = Transaction.find_by_id(params[:id])
    if @transaction.nil?
      render_404("Transaction not found") and return
    end
    @transaction.assign_attributes(filter_params)
    if @transaction.save!
      msg = @transaction.attributes
      render_200("Transaction updated", msg)
    else
      render_404("Some error occured")
    end
  end

  def delete
    @transaction = Transaction.find_by_id(params[:id])
    if @transaction.nil?
      render_404("Transaction not found") and return
    end
    @transaction.delete
    msg = @transaction.attributes
    render_200("Transaction deleted", msg)
  end

  private

  def filter_params
    params.permit(:account_id, :mop_id, :amount, :ttype, :date, :party, :category, :meta, :comments)
  end
end
