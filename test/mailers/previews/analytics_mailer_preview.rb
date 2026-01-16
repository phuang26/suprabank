# Preview all emails at http://localhost:3000/rails/mailers/analytics_mailer
class AnalyticsMailerPreview < ActionMailer::Preview
  def daily_report
    AnalyticsMailer.daily_report
  end

  def weekly_report
    AnalyticsMailer.weekly_report
  end

  def greet
    AnalyticsMailer.greet

  end
end
