# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/revision_mailer
class RevisionMailerPreview < ActionMailer::Preview
  def report
    RevisionMailer.report
  end

  def reviewer_report
    reviewer = User.find(541_534_003)
    RevisionMailer.reviewer_report(reviewer)
  end

  def user_report
    user = User.find(2)
    RevisionMailer.user_report(user)
  end

  def update_info
    user = User.find(2)
    RevisionMailer.update_info(user)
  end
end
