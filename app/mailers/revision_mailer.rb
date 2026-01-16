class RevisionMailer < ApplicationMailer

  def report
    @interactions = Interaction.under_revision
    @date = Time.zone.now.to_date.strftime("%A %d. %B %Y")
    mail(
      to: "contact@suprabank.org",
      subject: "Daily Revisions Report of SupraBank | #{ENV['LOGOENV']}"
    )
  end

  def reviewer_report(reviewer)
    @reviewer = User.find(reviewer)
    @interactions = Interaction.reviewerscope(@reviewer).under_revision
    @date = Time.zone.now.to_date.strftime("%A %d. %B %Y")
    mail(to: @reviewer.email,
          subject: "Revisions Report of SupraBank | #{ENV['LOGOENV']}")
  end

  def user_report(user)
    @user = User.find(user)
    @interactions = @user.interactions.under_revision
    @date = Time.zone.now.to_date.strftime("%A %d. %B %Y")
    mail(to: @user.email,
          subject: "Your personal Revisions Report of SupraBank")
  end

  def update_info(user)
    @user = User.find(user)
    @interactions = @user.interactions.under_revision
    @date = Time.zone.now.to_date.strftime("%A %d. %B %Y")
    mail(to: @user.email,
          subject: "New Revision System on SupraBank")
  end

end
