class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email(user)
    @user = user
    @url  = 'http://example.com/login'
    @user.email = "contact@suprabank.org"
    @molecules = Molecule.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end

  def some_mail
    @molecules = Molecule.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
    mail(to: "contact@suprabank.org", subject: 'Welcome to My Awesome Site')
  end



end
