class AssignmentMailer < ApplicationMailer
  default from: 'Group Assignments <no-reply@suprabank.org>'


  def group_assignment_request(assignment = Assignment.find(25))
    @assignment = assignment
    @user = @assignment.user
    @group = @assignment.group
    @desired_group = @assignment.desired_group
    mail(to: "#{ENV['CONTACTMAIL']}", subject: "Group assignment request from #{@user.full_name} | #{ENV['LOGOENV']}")
  end

end
