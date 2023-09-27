class Account < ApplicationRecord
  belongs_to :user
  has_many :transactions
  has_many :daily_logs
  has_many :cards
  has_many :mops

  after_create :after_create_action
  after_commit :after_save_action, on: [:create, :update]
  after_destroy :after_delete_action

  def after_save_action
    Websocket.publish(ACCOUNTS_CHANNEL, 'refresh')
  end

  def after_delete_action
    self.cards.each do |card|
      card.destroy
    end
    self.mops.each do |mop|
      mop.destroy
    end
    Websocket.publish(ACCOUNTS_CHANNEL, 'refresh')
  end

  def after_create_action
    self.add_opening_transaction
  end

  def add_opening_transaction
    balance = self.balance
    mop = Mop.create("auto_generated", self, {"auto_generated" => true})
    self.add_opening_balance(balance, mop, self.opening_date)
  end



  def add_opening_balance(amount, mop, date)
    transaction = Transaction.account_opening(amount, mop, date, self)
    # self.update_balance(transaction)
    self.update_daily_log(transaction)
  end

  def update_balance(transaction)
    self.balance += transaction.get_difference(self)
    self.save!
  end

  def update_daily_log(transaction)
    log = self.daily_logs.find_by(date: transaction.date)
    if log.nil?
      meta = {"tr_ids" => []}
      if self.daily_logs.blank?
        log = DailyLog.new(opening_balance: 0, closing_balance: 0, account_id: self.id, user_id: transaction.user_id, meta: meta, date: transaction.date, total_transactions: 0)
        log.save!
      else
        opening_balance = self.daily_logs.where("date < ?", transaction.date).order(date: :desc).first&.closing_balance
        log = DailyLog.new(opening_balance: opening_balance, closing_balance: opening_balance, account_id: self.id, user_id: transaction.user_id, meta: meta, date: transaction.date, total_transactions: 0)
        log.save!
      end
    end
    log.add_transaction(transaction, self)
  end

  def self.create_credit_card_account(name, user)
    attributes = {}
    attributes[:name] ="creditcard_#{name}"
    attributes[:creditcard] = true
    attributes[:user_id] = user.id
    attributes[:balance] = 0
    attributes[:opening_date] = Date.today
    @account = Account.new(attributes)
    @account.save!
    return @account
  end

  def self.list(user, owed=false)
    array = []
    accounts = user.accounts.where(creditcard: false, owed: owed)
    accounts.each do |account|
      account['name'] = account['name'].titleize
      temp = account.attributes
      temp['transactions'] = account.transactions.order(date: :desc, updated_at: :desc).limit(5).map{|t| t.transaction_box }
      array << temp
    end
    array
  end

  def auto_generated_mop
    self.mops.find{|m| m.is_auto_generated?}
  end

  def owed_transactions
    return nil unless self.owed
    self.user.transactions.where(party: self.id)
  end
end
