# Preview all emails at http://localhost:3000/rails/mailers/usermailer
class AssignmentMailerPreview < ActionMailer::Preview


  def group_assignment_request
    AssignmentMailer.group_assignment_request
  end
end
