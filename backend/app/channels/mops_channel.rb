class MopsChannel < ApplicationCable::Channel
  def subscribed
    stream_from MOPS_CHANNEL
  end

  # Other channel methods...
end
  