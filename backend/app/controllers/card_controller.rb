class CardController < ApplicationController
  before_action :check_current_user

  def index
    cards = @current_user.cards
    json = { CREDITCARD => [], DEBITCARD => []}
    cards.each do|card|
      card_json = card.attributes
      if card.ctype == CREDITCARD
        json[CREDITCARD] << card_json
      else
        card_json['account'] = card.account.name
        json[DEBITCARD] << card_json
      end
    end
    render(:json => json)
  end

  def create
    name = Util.processed_name(filter_params[:name])
    if CTYPES.exclude? filter_params[:ctype]
      render_400("Invalid ctype") and return
    end
    account = Account.create_credit_card_account(name, @current_user) if filter_params[:ctype] == CREDITCARD
    attributes = filter_params.slice(:ctype)
    attributes[:name] = name
    attributes[:account_id] = filter_params[:ctype] == DEBITCARD ? filter_params[:account_id] : account.reload.id
    attributes[:user_id] = @current_user.id
    @card = Card.new(attributes)
    
    begin
      @card.save!
      msg = @card.attributes
      render_200("Card created", msg)
    rescue StandardError => ex
      render_400(ex.message)
    end
  end

  def update
    @card = Card.find_by_id(params[:id])
    if @card.nil?
      render_404("Card not found") and return
    end
    @card.assign_attributes(filter_params)
    begin
      @card.save!
      msg = @card.attributes
      render_200("Card updated", msg)
    rescue StandardError => ex
      render_400(ex.message)
    end
  end

  def delete
    @card = Card.find_by_id(params[:id])
    if @card.nil?
      render_404("Card not found") and return
    end
    begin
      @card.destroy
      msg = @card.attributes
      render_200("Card deleted", msg)
    rescue StandardError => ex
      render_400(ex.message)
    end
  end

  private

  def filter_params
    params.permit(:name, :account_id, :ctype, :outstanding_bill, :last_paid)
  end

end
