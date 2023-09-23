class LazyWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :low

  def perform(method_name, args={})
    if self.respond_to?(method_name)
      self.method(method_name).call(args)
    else
      puts "#{method_name} not found"
    end
  end

  def update_subsequent(args)
    transaction = Transaction.find_by_id(args['transaction_id'])
    transaction.update_subsequent
  end

end
  