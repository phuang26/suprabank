namespace :revisions do

  desc "Initializer"
  task start: :environment do
    puts "You are running all setups, that will take few minutes, get a coffee!"
  end


  desc "Send a report to reviewer if any assigned interaction"
  task reviewer_report: :environment do
    #find all interactions under revision, pending, accepted, submitted
    interactions = Interaction.submitted
    #get all user that are currently reviewing interactions
    current_reviewers = interactions.map{|i| i.reviewer_id}.uniq
    current_reviewers.each do |reviewer|
      RevisionMailer.reviewer_report(reviewer).deliver!
      puts "#{Time.now} — Success! Report sent to #{User.find(reviewer).full_name}"
    end
  end

  desc "Send a report to users"
  task user_report: :environment do
    #find all interactions under revision, pending, accepted, submitted
    interactions = Interaction.user_action
    #get all user that are currently reviewing interactions
    current_users = interactions.map{|i| i.user_id}.uniq
    current_users.each do |user|
      RevisionMailer.user_report(user).deliver!
      puts "#{Time.now} — Success! Report sent to #{User.find(user).full_name}"
    end
  end

  desc "Revision release update information"
  task update_info: :environment do
    #find all interactions under revision, pending, accepted, submitted
    interactions = Interaction.under_revision
    #get all user that are currently reviewing interactions
    current_users = interactions.map{|i| i.user_id}.uniq
    current_users.each do |user|
      RevisionMailer.update_info(user).deliver!
      puts "#{Time.now} — Success! Information sent to #{User.find(user).full_name}"
    end
  end





end
