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

  def admin_new_user_mail(new_user)
    mail to:       ADMIN_MAIL_ID,
         from:     "\"Audit\" <admin@domain.ch>",
         subject: 'New user intimation',
         body:    "#{new_user} has joined audit"
  end
end
