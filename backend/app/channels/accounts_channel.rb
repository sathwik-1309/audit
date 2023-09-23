class AccountsChannel < ApplicationCable::Channel
  def subscribed
    stream_from ACCOUNTS_CHANNEL
  end

  # Other channel methods...
end
  