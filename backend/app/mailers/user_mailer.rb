class UserMailer < ApplicationMailer
  def welcome(name, email)
    mail to:       email,
         from:     "\"Audit\" <admin@domain.ch>",
         subject: 'Welcome to Audit app',
         body:    "Hello #{name}, hope you enjoy the experience"
  end
end
