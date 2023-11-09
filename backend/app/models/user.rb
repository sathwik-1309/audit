class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  acts_as_token_authenticatable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :accounts
  has_many :mops
  has_many :cards
  has_many :transactions
  has_many :categories
  has_many :sub_categories

  after_create :after_create_action
  after_commit :after_save_action, on: [:create, :update]

  def after_create_action
    date = Date.today
    account = Account.new(name: CASH_ACCOUNT, balance: 0, user_id: self.id, opening_date: date)
    account.save!
    account2 = Account.new(name: 'Account 1', balance: 1000, user_id: self.id, opening_date: date)
    account2.save!
    party = Account.new(name: 'Friend 1', balance: 0, user_id: self.id, owed: true, opening_date: date)
    party.save!
    creditcard_account = Account.create_credit_card_account('Creditcard 1', self)
    creditcard = Card.new(name: 'Creditcard 1', ctype: CREDITCARD, user_id: self.id, account_id: creditcard_account.id)
    creditcard.save!
    debitcard = Card.new(name: 'Debitcard 1', ctype: DEBITCARD, user_id: self.id, account_id: account2.id)
    debitcard.save!
    category = Category.new(name: 'Travel', user_id: self.id, color: 'orange', budget: BUGDET_INIT, monthly_limit: 2000, yearly_limit: 24000)
    category.save!
    sub_cat1 = SubCategory.new(name: 'Fuel', budget: BUGDET_INIT, monthly_limit: 1000, yearly_limit: 12000, category_id: category.id, user_id: self.id)
    sub_cat1.save!
    sub_cat2 = SubCategory.new(name: 'Cabs', budget: BUGDET_INIT, monthly_limit: 1000, yearly_limit: 12000, category_id: category.id, user_id: self.id)
    sub_cat2.save!
    category2 = Category.new(name: 'Food', user_id: self.id, color: '#3498db', budget: BUGDET_INIT, monthly_limit: 5000, yearly_limit: 60000)
    category2.save!
    sub_cat3 = SubCategory.new(name: 'Food', budget: BUGDET_INIT, monthly_limit: 5000, yearly_limit: 60000, category_id: category2.id, user_id: self.id)
    sub_cat3.save!
    tr = Transaction.new(amount: 200, sub_category_id: sub_cat1.id, user_id: self.id, date: Date.today, ttype: DEBIT,
                        account_id: account2.id, category_id: category.id, comments: 'Sample Account Transaction')
    tr.save!
    tr = Transaction.new(amount: 100, sub_category_id: sub_cat2.id, user_id: self.id, date: Date.today, ttype: DEBIT,
      account_id: account.id, category_id: category.id, comments: 'Sample Cash Transaction')
    tr.save!
    tr = Transaction.new(amount: 150, sub_category_id: sub_cat3.id, user_id: self.id, date: Date.today, ttype: DEBIT,
      account_id: creditcard_account.id, category_id: category2.id, comments: 'Sample CreditCard Transaction', card_id: creditcard.id)
    tr.save!
  end

  def after_save_action
    Websocket.publish(USER_CHANNEL, 'refresh')
  end

  def debitcards
    self.cards.where(ctype: DEBITCARD)
  end

  def creditcards
    self.cards.where(ctype: CREDITCARD)
  end

  def cash_account
    self.accounts.find_by(name: CASH_ACCOUNT)
  end

  def send_reset_password_otp
    otp = rand(100_0..999_9)
    begin
      self.meta['reset_password_otp'] = [] if self.meta['reset_password_otp'].nil?
      self.meta['reset_password_otp'] << otp
      self.save!
      UserMailer.reset_password_otp(self.email, otp).deliver_now
    rescue StandardError => ex
      puts ex.message
    end
  end

  def upload(image)
    uploaded_file = image

    if uploaded_file.blank?
      render_400("Empty file upload") and return
    end

    # Construct the filename based on user_id or any desired logic
    filename = "user_#{self.id}.jpg"

    # Determine the directory where you want to save the file
    upload_directory = Rails.root.join('public', 'images')

    # Ensure the directory exists; create it if it doesn't
    FileUtils.mkdir_p(upload_directory) unless File.directory?(upload_directory)

    # Build the full file path
    file_path = File.join(upload_directory, filename)

    begin
      # Save the uploaded file to the specified directory
      File.open(file_path, 'wb') do |file|
        file.write(uploaded_file.read)
      end

      # Update the user's image_url
      self.image_url = filename
      self.save!
    rescue => e
      Rails.logger.error("Error saving file: #{e.message}")
      raise StandardError.new(e.message)
    end
  end

end
