class TransactionController < ApplicationController
  before_action :check_current_user

  def index
    if params[:account_id].present?
      @account = @current_user.accounts.find_by_id(filter_params[:account_id])
      @transactions = @account.transactions
    else
      @transactions = @current_user.transactions
    end
    render(:json => @transactions.to_json)
  end
  def create
    attributes = filter_params.slice(:account_id, :mop_id, :amount, :ttype, :date, :party, :category, :meta, :comments)
    attributes[:user_id] = @current_user.id
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
    @transaction.destroy
    msg = @transaction.attributes
    render_200("Transaction deleted", msg)
  end

  # required params - amount (mop_id/account_id)
  # optional params - date, category, comments, account_id, mop_id
  def debit
    attributes = filter_params.slice(:amount, :comments, :sub_category_id)
    if filter_params[:card_id].present?
      @card = @current_user.cards.find_by_id(filter_params[:card_id])
      mop = @card.mop
    elsif filter_params[:mop_id].present?
      mop = @current_user.mops.find_by_id(filter_params[:mop_id])
    elsif filter_params[:account_id].present?
      mop = @current_user.mops.where(account_id: filter_params[:account_id]).find{|m| m.is_auto_generated? }
    else
      render_202("Either mop_id or account_id must be sent in request") and return
    end

    if mop.nil?
      render_202("mop_id or account_id is invalid") and return
    end

    unless attributes[:sub_category_id].nil?
      attributes[:category_id] = @current_user.sub_categories.find_by_id(filter_params[:sub_category_id]).category_id
    end

    attributes[:user_id] = @current_user.id
    attributes[:ttype] = DEBIT
    attributes[:mop_id] = mop.id
    attributes[:account_id] = mop.account_id
    attributes[:date] = filter_params[:date].present? ? filter_params[:date] : Date.today
    begin
      @transaction = Transaction.create(attributes)
      @transaction.save!
      @card.update_outstanding_bill(attributes[:amount]) if !@card.nil? and @card.ctype == CREDITCARD
      msg = @transaction.attributes
      render_200("Debit Transaction added", msg) and return
    rescue StandardError => ex
      if ex.message == "Cannot add a transaction in past date of account opening"
        render_202("Cannot add a transaction in past date of account opening")
      else
        render_400(ex.message, {"error_message" => ex.message}) and return
      end
    end
  end

  def credit
    attributes = filter_params.slice(:amount, :category, :comments, :account_id)
    @account = Account.find_by_id(filter_params[:account_id])
    if @account.nil?
      render_202("account not found") and return
    end

    attributes[:user_id] = @current_user.id
    attributes[:ttype] = CREDIT
    attributes[:mop_id] = @account.auto_generated_mop.id
    attributes[:account_id] = @account.id
    attributes[:date] = filter_params[:date].present? ? filter_params[:date] : Date.today

    begin
      @transaction = Transaction.create(attributes)
      @transaction.save!
      msg = @transaction.attributes
      render_200("Credit Transaction added", msg) and return
    rescue StandardError => ex
      render_400(ex.message) and return
    end
  end

  # amount, party,
  # date, category, comments
  def paid_by_party
    attributes = filter_params.slice(:amount, :party, :sub_category_id, :comments)
    @account = Account.find_by_id(filter_params[:party])
    if @account.nil?
      render_202("party not found") and return
    end

    attributes[:user_id] = @current_user.id
    attributes[:ttype] = PAID_BY_PARTY
    attributes[:mop_id] = @account.auto_generated_mop.id
    attributes[:account_id] = @account.id
    attributes[:date] = filter_params[:date].present? ? filter_params[:date] : Date.today
    attributes[:party] = @account.id
    unless attributes[:sub_category_id].nil?
      attributes[:category_id] = @current_user.sub_categories.find_by_id(filter_params[:sub_category_id]).category_id
    end

    begin
      @transaction = Transaction.create(attributes)
      @transaction.save!
      msg = @transaction.attributes
      render_200("Paid by party Transaction added", msg) and return
    rescue StandardError => ex
      render_400(ex.message) and return
    end
  end

  # amount, party, account_id/card_id/mop_id
  # date, comments, 
  def paid_by_you
    attributes = filter_params.slice(:amount, :party, :comments)
    @party = Account.find_by_id(filter_params[:party])
    if @party.nil?
      render_202("party not found") and return
    end

    if filter_params[:card_id].present?
      mop = @current_user.cards.find_by_id(filter_params[:card_id]).mop
    elsif filter_params[:mop_id].present?
      mop = @current_user.mops.find_by_id(filter_params[:mop_id])
    elsif filter_params[:account_id].present?
      mop = @current_user.mops.where(account_id: filter_params[:account_id]).find{|m| m.is_auto_generated? }
    else
      render_202("Either mop_id or account_id must be sent in request") and return
    end

    if mop.nil?
      render_202("mop_id or account_id is invalid") and return
    end

    attributes[:user_id] = @current_user.id
    attributes[:ttype] = PAID_BY_YOU
    attributes[:mop_id] = mop.id
    attributes[:account_id] = mop.account_id
    attributes[:date] = filter_params[:date].present? ? filter_params[:date] : Date.today
    attributes[:party] = @party.id

    begin
      @transaction = Transaction.create(attributes)
      @transaction.save!
      msg = @transaction.attributes
      render_200("Paid by you Transaction added", msg) and return
    rescue StandardError => ex
      render_400(ex.message) and return
    end
  end

  # amount, party, account_id
  # date, comments
  def settled_by_party
    attributes = filter_params.slice(:amount, :comments, :account_id)
    @account = Account.find_by_id(filter_params[:account_id])
    if @account.nil?
      render_202("account not found") and return
    end
    @party = Account.find_by_id(filter_params[:party])
    if @party.nil?
      render_202("party not found") and return
    end

    attributes[:user_id] = @current_user.id
    attributes[:ttype] = SETTLED_BY_PARTY
    attributes[:mop_id] = @account.auto_generated_mop.id
    attributes[:account_id] = @account.id
    attributes[:date] = filter_params[:date].present? ? filter_params[:date] : Date.today
    attributes[:party] = @party.id

    begin
      @transaction = Transaction.create(attributes)
      @transaction.save!
      msg = @transaction.attributes
      render_200("Settled by party Transaction added", msg) and return
    rescue StandardError => ex
      render_202(ex.message) and return
    end
  end

  def settled_by_you
    @party = Account.find_by_id(filter_params[:party])
    if @party.nil?
      render_202("party not found") and return
    end
    attributes = filter_params.slice(:amount, :comments)
    if filter_params[:card_id].present?
      mop = @current_user.cards.find_by_id(filter_params[:card_id]).mop
    elsif filter_params[:mop_id].present?
      mop = @current_user.mops.find_by_id(filter_params[:mop_id])
    elsif filter_params[:account_id].present?
      mop = @current_user.mops.where(account_id: filter_params[:account_id]).find{|m| m.is_auto_generated? }
    else
      render_202("Either mop_id or account_id must be sent in request") and return
    end

    if mop.nil?
      render_202("mop_id or account_id is invalid") and return
    end

    attributes[:user_id] = @current_user.id
    attributes[:ttype] = SETTLED_BY_YOU
    attributes[:mop_id] = mop.id
    attributes[:account_id] = mop.account_id
    attributes[:date] = filter_params[:date].present? ? filter_params[:date] : Date.today
    attributes[:party] = @party.id

    begin
      @transaction = Transaction.create(attributes)
      @transaction.save!
      msg = @transaction.attributes
      render_200("Settled by you Transaction added", msg) and return
    rescue StandardError => ex
      render_400(ex.message) and return
    end
  end

  # amount, transactions, card_id/account_id/mop_id
  # date, category, comments,
  def split
    attributes = filter_params.slice(:amount, :comments)
    if filter_params[:card_id].present?
      mop = @current_user.cards.find_by_id(filter_params[:card_id]).mop
    elsif filter_params[:mop_id].present?
      mop = @current_user.mops.find_by_id(filter_params[:mop_id])
    elsif filter_params[:account_id].present?
      mop = @current_user.mops.where(account_id: filter_params[:account_id]).find{|m| m.is_auto_generated? }
    else
      render_202("Either mop_id or account_id must be sent in request") and return
    end

    if mop.nil?
      render_202("mop_id or account_id is invalid") and return
    end

    attributes[:user_id] = @current_user.id
    attributes[:mop_id] = mop.id
    attributes[:account_id] = mop.account_id
    attributes[:ttype] = SPLIT
    attributes[:date] = filter_params[:date].present? ? filter_params[:date] : Date.today
    tr_array = filter_params[:transactions].map(&:to_h)
    amounts_arr = tr_array.map{|t| t['amount'].to_f}
    if amounts_arr.sum != filter_params[:amount].to_f
      render_202("Sum does not add up to the amount #{filter_params[:amount]}") and return
    end

    begin
      @transaction = Transaction.create(attributes)
      @transaction.save!
      LazyWorker.perform_async('create_split_transactions', { "transaction_id" => @transaction.id, "tr_array" => tr_array } )
      msg = @transaction.attributes
      render_200("Split transactions will be added", msg) and return
    rescue StandardError => ex
      render_400(ex.message) and return
    end

  end

  def dashboard
    json = {}
    json['accounts'] = Account.list(@current_user)
    if params[:owed_id].present?
      json['owed_account'] = @current_user.accounts.find_by_id(params[:owed_id]).attributes
    else
      json['owed_accounts'] = Account.list(@current_user, true)
    end
    json['mops'] = @current_user.mops.select{|m| !m.is_auto_generated? and !m.is_card? }.map {|m| { "id"=> m.id, "name" => m.name}}
    json['cards'] = @current_user.cards.map {|c| {"id"=>c.id, "name"=> c.name}}
    json['sub_categories'] = @current_user.sub_categories.map{|c| {"id"=> c.id, "name"=> c.name}}
    render(:json => json)
  end

  private

  def filter_params
    params.permit(:account_id, :mop_id, :amount, :ttype, :date, :party, :meta, :comments, :card_id, :sub_category_id, transactions: [:amount, :user, :party])
  end

end
