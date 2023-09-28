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

  def debitcards
    self.cards.where(ctype: DEBITCARD)
  end

  def creditcards
    self.cards.where(ctype: CREDITCARD)
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

end
