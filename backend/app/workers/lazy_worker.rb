class LazyWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :low

  def perform(method_name, args={})
    if self.respond_to?(method_name)
      puts "LazyWorker##{method_name}: args: #{args}"
      self.method(method_name).call(args)
    else
      puts "#{method_name} not found"
    end
  end

  def update_subsequent(args)
    transaction = Transaction.find_by_id(args['transaction_id'])
    if args['account_id'].present?
      transaction.update_subsequent(Account.find_by_id(args['account_id']))
    else
      transaction.update_subsequent
    end

  end

  def send_welcome_email(args)
    begin
      UserMailer.welcome(args['name'], args['email']).deliver_now
    rescue => ex
      puts "LazyWorker#send_welcome_email: Error send email: #{ex.message}"
    end
  end

  def send_admin_new_user_mail(args)
    begin
      AdminMailer.new_user_mail(args['name']).deliver_now
    rescue => ex
      puts "LazyWorker#send_welcome_email: Error send email: #{ex.message}"
    end
  end

  def create_split_transactions(args)
    transaction = Transaction.find_by_id(args['transaction_id'])
    transaction.create_split_transactions(args['tr_array'])
  end

end
  