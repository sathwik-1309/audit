class CategoryChannel < ApplicationCable::Channel
  def subscribed
    stream_from CATEGORY_CHANNEL
  end

  # Other channel methods...
end
