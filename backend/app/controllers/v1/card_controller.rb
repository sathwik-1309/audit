class V1::CardController < ApplicationController
  before_action :check_current_user

  def details
    card = @current_user.cards.find_by_id(params[:id])
    if card.nil?
      render_202("Card not found") and return
    end
    if card.ctype == DEBITCARD
      json = card.debitcard_details
    else
      json = card.creditcard_details
    end
    render(:json => Oj.dump(json))
  end

  def pay_bill
    card = @current_user.cards.find_by_id(params[:id])
    if card.nil?
      render_202("Card not found") and return
    end
    if card.ctype == DEBITCARD
      render_202("Provide a creditcard") and return
    end
    # meta = {'card_id' => card.id}
    transaction = Transaction.new(amount: filter_params[:amount], ttype: CREDIT, date: Date.today,
      comments: filter_params[:comments], account_id: card.account_id, user_id: @current_user.id, meta: meta,
      card_id: card.id)
    begin
      transaction.save!
      card.outstanding_bill -= filter_params[:amount].to_f
      card.save!
      render_200("Card updated")
    rescue StandardError => ex
      render_202(ex.message)
    end
  end

  private

  def filter_params
    params.permit(:id, :start_date, :end_date, :month, :year, :amount, :comments)
  end
end