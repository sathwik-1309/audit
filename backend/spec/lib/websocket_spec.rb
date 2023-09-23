# spec/channels/accounts_channel_spec.rb
require 'rails_helper'

describe Websocket do
  it 'broadcasts a message to the channel' do
    expect { Websocket.publish(ACCOUNTS_CHANNEL, 'hello') }.to have_broadcasted_to(ACCOUNTS_CHANNEL)
                                                              .with(a_hash_including('message' => 'hello'))
  end
end


