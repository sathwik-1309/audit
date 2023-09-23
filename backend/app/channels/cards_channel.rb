class CardsChannel < ApplicationCable::Channel
  def subscribed
    stream_from CARDS_CHANNEL
  end

  # Other channel methods...
end
