class AnalyticsMailer < ApplicationMailer
  default cc: "contact@suprabank.org"
  default to: "reports.uqdd1l@zapiermail.com"

  def daily_report
    @molecules = Molecule.where(created_at: Time.zone.yesterday.beginning_of_day..Time.zone.yesterday.end_of_day)
    @interactions = Interaction.active.where(created_at: Time.zone.yesterday.beginning_of_day..Time.zone.yesterday.end_of_day)
    @additives = Additive.where(created_at: Time.zone.yesterday.beginning_of_day..Time.zone.yesterday.end_of_day)
    @solvents = Solvent.where(created_at: Time.zone.yesterday.beginning_of_day..Time.zone.yesterday.end_of_day)
    @buffers = Buffer.where(created_at: Time.zone.yesterday.beginning_of_day..Time.zone.yesterday.end_of_day)
    @users = User.where(created_at: Time.zone.yesterday.beginning_of_day..Time.zone.yesterday.end_of_day)
    @date = Time.zone.yesterday.to_date.strftime("%A %d. %B %Y")
    mail(subject: "Daily Report of SupraBank | #{ENV['LOGOENV']}")
  end

  def weekly_report
    @molecules = Molecule.where(created_at: Time.zone.yesterday.beginning_of_week..Time.zone.yesterday.end_of_week)
    @interactions = Interaction.active.where(created_at: Time.zone.yesterday.beginning_of_week..Time.zone.yesterday.end_of_week)
    @additives = Additive.where(created_at: Time.zone.yesterday.beginning_of_week..Time.zone.yesterday.end_of_week)
    @solvents = Solvent.where(created_at: Time.zone.yesterday.beginning_of_week..Time.zone.yesterday.end_of_week)
    @buffers = Buffer.where(created_at: Time.zone.yesterday.beginning_of_week..Time.zone.yesterday.end_of_week)
    @users = User.where(created_at: Time.zone.yesterday.beginning_of_week..Time.zone.yesterday.end_of_week)
    @date = "#{Time.zone.yesterday.beginning_of_week.to_date.strftime("%A %d. %B %Y")} - #{Time.zone.yesterday.end_of_week.to_date.strftime("%A %d. %B %Y")}"
    mail(subject: "Weekly Report of SupraBank | #{ENV['LOGOENV']}")
  end

  def greet
    mail(
      to: 'to@example.com',
      from: 'from@example.com',
      subject: 'Hi From Bootstrap Email',
    )
  end
end
