class AdminMailer < ApplicationMailer
  def new_user_mail(new_user)
    mail to:       ADMIN_MAIL_ID,
         from:     "\"Audit\" <admin@domain.ch>",
         subject: 'New user intimation',
         body:    "#{new_user} has joined audit"
  end

  def error_mailer(method, error)
    mail to:       ADMIN_MAIL_ID,
         from:     "\"Audit\" <admin@domain.ch>",
         subject: 'New user intimation',
         body:    "Error occurred in #{method}: #{error}"
  end
end
