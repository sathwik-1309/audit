class UserMailer < ApplicationMailer
  def welcome(name, email)
    mail to:       email,
         from:     "\"Audit\" <admin@domain.ch>",
         subject: 'Welcome to Audit app',
         body:    "Hello #{name}, hope you enjoy the experience"
  end

  def reset_password_otp(email, otp)
    mail to: email,
         from: "\"Audit\" <admin@domain.ch>",
         subject: "Reset Password OTP",
         body: "Your OTP for resetting password is #{otp}"
  end
end
