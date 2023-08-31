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

  def debitcards
    self.cards.where(ctype: DEBITCARD)
  end

  def creditcards
    self.cards.where(ctype: CREDITCARD)
  end

end
