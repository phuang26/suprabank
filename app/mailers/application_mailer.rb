class ApplicationMailer < ActionMailer::Base
  default from: 'SupraBank Notifications <no-reply@suprabank.org>'
  layout 'mailer'
  #layout 'bootstrap-mailer'
end
