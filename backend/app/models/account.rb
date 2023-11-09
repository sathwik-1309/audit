class Account < ApplicationRecord
  belongs_to :user
  has_many :transactions
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
  end

  def update_balance(transaction)
    self.balance += transaction.get_difference(self)
    self.save!
  end

  # def update_daily_log(transaction)
  #   log = self.daily_logs.find_by(date: transaction.date)
  #   if log.nil?
  #     meta = {"tr_ids" => []}
  #     if self.daily_logs.blank?
  #       log = DailyLog.new(opening_balance: 0, closing_balance: 0, account_id: self.id, user_id: transaction.user_id, meta: meta, date: transaction.date, total_transactions: 0)
  #       log.save!
  #     else
  #       opening_balance = self.daily_logs.where("date < ?", transaction.date).order(date: :desc).first&.closing_balance
  #       log = DailyLog.new(opening_balance: opening_balance, closing_balance: opening_balance, account_id: self.id, user_id: transaction.user_id, meta: meta, date: transaction.date, total_transactions: 0)
  #       log.save!
  #     end
  #   end
  #   log.add_transaction(transaction, self)
  # end

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
      temp = account.attributes
      if owed
        transactions = account.owed_transactions
      else
        transactions = account.transactions
      end
      temp['transactions'] = transactions.order(date: :desc, updated_at: :desc).limit(5).map{|t| t.transaction_box }
      array << temp
    end
    array
  end

  def pie_chart_meta(start_date, end_date)
    meta_array = []
    meta = {}
    transactions = self.transactions.where("date between ? and ?",start_date, end_date).where(ttype: [DEBIT, PAID_BY_PARTY])
    transactions.each do|transaction|
      if transaction.category.present?
        meta[transaction.category.name] = 0 unless meta.has_key? transaction.category.name
        meta[transaction.category.name] += transaction.amount
      else
        meta['other'] = 0 unless meta.has_key? 'other'
        meta['other'] += transaction.amount
      end
    end

    total_amount = meta.values.sum
    id = 0
    meta.each do |category, amount|
      meta_array << {
        "id" => id,
        "value" => amount,
        "color" => PIE_CHART_COLORS[id],
        "percentage" => (amount*100/total_amount).round(2),
        "label" => category
      }
      id += 1
    end
    meta_array
  end

  def pie_chart_meta_sub_category(category)
    meta_array = []
    meta = {}
    transactions = self.transactions.where(ttype: [DEBIT, PAID_BY_PARTY], category_id: category.id)
    transactions.each do|transaction|
      if transaction.sub_category.present?
        meta[transaction.sub_category.name] = 0 unless meta.has_key? transaction.sub_category.name
        meta[transaction.sub_category.name] += transaction.amount
      else
        meta['other'] = 0 unless meta.has_key? 'other'
        meta['other'] += transaction.amount
      end
    end
    total_amount = meta.values.sum
    id = 0
    meta.each do |sub_category, amount|
      meta_array << {
        "id" => id,
        "value" => amount,
        "color" => PIE_CHART_COLORS[id],
        "percentage" => (amount*100/total_amount).round(2),
        "label" => sub_category
      }
      id += 1
    end
    meta_array
  end

  def auto_generated_mop
    self.mops.find{|m| m.is_auto_generated?}
  end

  def owed_transactions
    return [] unless self.owed
    self.user.transactions.where(party: self.id)
  end

  def stats(start_date, end_date)
    transactions = self.transactions.where(pseudo: false)
    if start_date.present? and end_date.present?
      transactions = transactions.where("date BETWEEN ? AND ?", start_date, end_date)
    end
    total = { CREDIT => 0, DEBIT => 0}
    transactions.each do |transaction|
      if transaction.get_difference(self) > 0
        total[CREDIT] += transaction.amount
      else
        total[DEBIT] += transaction.amount
      end
    end
    total["net"] = total[CREDIT] - total[DEBIT]
    total
  end
end
