class HardWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :high

  def perform(method_name, args={})
    if self.respond_to?(method_name)
      self.method(method_name).call(args)
    else
      puts "#{method_name} not found"
    end
  end

end
  