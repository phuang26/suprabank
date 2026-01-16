# Preview all emails at http://localhost:3000/rails/mailers/usermailer
class UserMailerPreview < ActionMailer::Preview

  def some_mail
    UserMailer.some_mail
  end

  def group_assignment_request
    UserMailer.group_assignment_request
  end
end
