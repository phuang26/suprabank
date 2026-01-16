namespace :analytics do

  desc "Initializer"
  task start: :environment do
    puts "You are running all setups, that will take few minutes, get a coffee!"
  end


  desc "Send a daily report to contact@suprabank.org"
  task daily_report: :environment do
    if ENV['LOGOENV'] == 'production'
      AnalyticsMailer.daily_report.deliver!
      puts "#{Time.now} — Success!"
    end
  end

  desc "Send a daily report to contact@suprabank.org"
  task weekly_report: :environment do
    if ENV['LOGOENV'] == 'production' ##just kick this out and connect to VPN for KIT access, to test in dev
      AnalyticsMailer.weekly_report.deliver!
      puts "#{Time.now} — Success!"
    end
  end

end
