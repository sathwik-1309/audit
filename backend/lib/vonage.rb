class SMS

  def self.client
    client = Vonage::Client.new(
      api_key: "61d5ea42",
      api_secret: "r8vDLKmTHJ0WOdgr"
    )
  end

  def self.send( text, to, from="Audit")
    client = SMS.client
    client.sms.send(
      from: from,
      to: to,
      text: text
    )
  end

end

