require "colors"
include Colors

namespace :orcid do

  desc "Initializer"
  task start: :environment do
    puts yellow "This is the orcid rake utility of SupraBank"
  end

  desc "Update missing ORCID ids of creators by name comparison"
  task creators: :environment do
    puts yellow "Task: update missing ORCID ids by name comparison to creators"
    creators = Creator.where(nameIdentifier: [nil, ""])
    if creators.present?
      Parallel.each(creators, :batch_size => 100, progress: "#{green 'ORCID'} auto updating", in_processes: 4) do |creator|
        creator.automatic_orcid_assignment
        if creator.nameIdentifier_changed?
          puts "#{cyan Time.now} - #{green "Found an ORCID ID"}"
          if  creator.save
            puts "#{cyan Time.now} - #{green "Success!"} the creator #{creator.id} got an ORCID id assigned."
          else
            puts "#{cyan Time.now} - #{red "Failed!"} Errors: #{creator.errors.full_messages}."
          end #save contitional
        else
          puts "#{cyan Time.now} - #{red "Did not find any ORCID ID"}."
        end #change contitional
      end #creators batch
      begin
        ActiveRecord::Base.connection.reconnect!
      end
    end #presence conditional
      puts "Current status of Creators at #{cyan Time.now} \nCreators: #{blue Creator.count} in total and #{green Creator.where.not(nameIdentifier: nil).count} with ORCID."
  end

  desc "Update missing ORCID ids of contributors by name comparison"
  task contributors: :environment do
    puts yellow "Task: update missing ORCID ids by name comparison to contributors"
    contributors = Contributor.where(nameIdentifier: [nil, ""])
    if contributors.present?
      contributors.find_each(:batch_size => 1000) do |contributor|
        contributor.automatic_orcid_assignment
        if contributor.nameIdentifier_changed?
          if  contributor.save
            puts "#{cyan Time.now} - #{green "Success!"} the contributor #{contributor.id} got an ORCID id assigned."
          else
            puts "#{cyan Time.now} - #{red "Failed!"} Errors: #{contributor.errors.full_messages}."
          end #save contitional
        end #change contitional
      end #creators batch
    end #presence conditional
      puts "Current status of Contributors at #{cyan Time.now} \nContributors: #{blue Contributor.count} in total and #{green Contributor.where.not(nameIdentifier: nil).count} with ORCID."
  end

  desc "Update missing ORCID ids of users by name comparison"
  task users: :environment do
    puts yellow "Task: update missing ORCID ids by name comparison to users"
    users = User.where(nameIdentifier: [nil, ""])
    if users.present?
      users.find_each(:batch_size => 1000) do |user|
        user.automatic_orcid_assignment
        if user.nameIdentifier_changed?
          if  user.save
            puts "#{cyan Time.now} - #{green "Success!"} the user #{user.id} got an ORCID id assigned."
          else
            puts "#{cyan Time.now} - #{red "Failed!"} Errors: #{user.errors.full_messages}."
          end #save contitional
        end #change contitional
      end #creators batch
    end #presence conditional
      puts "Current status of Users at #{cyan Time.now} \nUsers: #{blue User.count} in total and #{green User.where.not(nameIdentifier: nil).count} with ORCID."
  end



  desc "Runner"
  task :runall => [:start, :creators, :contributors, :users] do
    # This will run after all those tasks have run
  end


end
