class Websocket
  def self.publish(channel, message)
    status = ActionCable.server.broadcast(channel, message)
    # puts "Websocket#publish: status is #{status}"
  end
end