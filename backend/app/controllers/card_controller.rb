class CardController < ApplicationController
  before_action :check_current_user

  def index
    cards = current_user.cards
    render(:json => cards.to_json)
  end

  def create
    if CTYPES.exclude? filter_params[:ctype]
      render_400("Invalid ctype") and return
    end
    attributes = filter_params.slice(:name, :account_id, :ctype)
    attributes[:user_id] = current_user.id
    @card = Card.new(attributes)
    if @card.save!
      msg = @card.attributes
      render_200("Card created", msg)
    else
      render_404("Some error occured")
    end
  end

  def update
    @card = Card.find_by_id(params[:id])
    if @card.nil?
      render_404("Card not found") and return
    end
    @card.assign_attributes(filter_params)
    if @card.save!
      msg = @card.attributes
      render_200("Card updated", msg)
    else
      render_404("Some error occured")
    end
  end

  def delete
    @card = Card.find_by_id(params[:id])
    if @card.nil?
      render_404("Card not found") and return
    end
    @card.delete
    msg = @card.attributes
    render_200("Card deleted", msg)
  end

  private

  def filter_params
    params.permit(:name, :account_id, :ctype, :outstanding_bill, :last_paid)
  end

end
