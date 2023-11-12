class Account < ApplicationRecord
  belongs_to :user
  has_many :transactions
  has_many :cards
  has_many :mops

  after_create :after_create_action
  after_commit :after_save_action, on: [:create, :update]
  before_destroy :before_delete_action

  def after_save_action
    Websocket.publish(ACCOUNTS_CHANNEL, 'refresh')
  end

  def before_delete_action
    self.cards.each do |card|
      card.destroy
    end
    self.mops.each do |mop|
      mop.destroy
    end
    self.transactions.each do |tr|
      tr.delete
    end
    Websocket.publish(ACCOUNTS_CHANNEL, 'refresh')
  end

  def after_create_action
    self.add_opening_transaction
  end

  def add_opening_transaction
    balance = self.balance
    self.add_opening_balance(balance, self.opening_date)
  end


  def add_opening_balance(amount, date)
    transaction = Transaction.account_opening(amount, date, self)
  end

  def update_balance(transaction, action='create')
    amount = action == 'create' ? transaction.get_difference(self) : - transaction.get_difference(self)
    self.balance += amount
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
    accounts = user.accounts.where(creditcard: false, owed: owed).where.not(name: CASH_ACCOUNT)
    accounts.each do |account|
      temp = account.attributes.slice('id', 'name', 'balance', 'owed')
      temp['formatted_balance'] = Util.format_amount(account.balance, @current_user)
      if owed
        transactions = account.owed_transactions
      else
        transactions = account.transactions.where(pseudo: false)
      end
      temp['transactions'] = transactions.order(date: :desc, t_order: :desc).limit(5).map{|t| t.transaction_box }
      temp['mops'] = account.mops.map{|mop| mop.attributes.slice('id', 'name')}
      array << temp
    end
    array
  end

  def is_cash?
    return true if self.name == CASH_ACCOUNT
    false
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

  def move_opening_transaction(date, diff_amount)
    opening_tr = self.transactions.find{|tr| tr.account_opening?}
    raise StandardError.new("Transaction is not account opening") unless opening_tr.account_opening?
    opening_bal = opening_tr.amount - diff_amount
    raise StandardError.new("Unable to delete the account opening transation") unless opening_tr.delete
    return self.reload.add_opening_balance(opening_bal, date)
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

    total["net"] = Util.format_amount(total[CREDIT] - total[DEBIT], self.user)
    total[CREDIT] = Util.format_amount(total[CREDIT], self.user)
    total[DEBIT] = Util.format_amount(total[DEBIT], self.user)
    
    total
  end
end
