require "colors"
include Colors

namespace :datasets do

  desc "Initializer"
  task start: :environment do
    puts "You are running all setups, that will take few minutes, get a coffee!"
  end

  desc "Create some Creators"
  task creators: :environment do
    puts "Three creators will be created."
      Creator.create!({givenName: "Stephan", familyName:"Sinn", nameIdentifier:"0000-0002-9676-9839", affiliation:"Karlsruhe Institute of Technology", affiliationIdentifier:"https://ror.org/04t3en479"})
      Creator.create!({givenName: "Frank", familyName:"Biedermann", nameIdentifier:"0000-0002-1077-6529", affiliation:"Karlsruhe Institute of Technology", affiliationIdentifier:"https://ror.org/04t3en479"})
      Creator.create!({givenName: "Katharina", familyName:"Wendler", nameIdentifier:"0000-0002-2767-9012", affiliation:"Karlsruhe Institute of Technology", affiliationIdentifier:"https://ror.org/04t3en479"})
  end


  desc "Update all datasets"
  task :updater => :environment do
    datasets = Dataset.all
    if datasets.present?
      progressbar = ProgressBar.create(:total => datasets.size, :format => "%a %b\u{15E7}%i %p%% %t", :progress_mark  => ' ', :remainder_mark => "\u{FF65}", :title => "#{green 'Interactions Transfer'}", :starting_at => 0)
      summary_statistics = {:success => 0, :failed => 0, :audit_failed => 0}
      Parallel.each(datasets, :batch_size => 1000, progress: "#{green 'Dataset'} registration") do |dataset|
        identifier = dataset.related_identifier
        if identifier.crossref.present?
          puts "The title of the identifier is #{identifier.crossref["title"]}, its id is: #{identifier.id}"
          dataset.title = dataset.related_identifier.crossref["title"]
          dataset.meta_updater
          if dataset.creators.blank? && dataset.related_identifier.crossref["author"].present?
            authors=dataset.related_identifier.crossref["author"].each{|obj| obj.deep_symbolize_keys!}
            dataset.initialize_creator_references(authors)#works
            dataset.save
          end
        else
          dataset.title = "Please fill title and authors manually #{dataset.primary_reference}"
        end

          if dataset.save
            puts "#{cyan Time.now} - #{green "Success!"} Dataset #{dataset.id} was registered, containing #{dataset.interactions.count} interactions. It belongs to: #{dataset.users.first.full_name}"
            summary_statistics[:success]+=1
          else
            puts "#{cyan Time.now} - #{red "Failed!"} An error occured: #{dataset.errors.full_messages}"
            summary_statistics[:failed]+=1
          end
        progressbar.increment
      end #batch loop
      begin
        ActiveRecord::Base.connection.reconnect!
      rescue
        ActiveRecord::Base.connection.reconnect!
      end
      puts "#{cyan Time.now} - #{green("Done with registering the drafted datasets.")}"
      puts summary_statistics
    end #presence contitional
  end

  desc "Non Singleton Datasets for existing interactions"
  task ns_draft: :environment do
    puts "Search all singleton (one user) interactions with a valid DOI and bundle them to appropriate datasets."
    #interactions = Interaction.active.where.not(doi: nil).where(doi_validity: true).map{|i| [i.doi, i.user_id]}.uniq #for development
    if Rails.env = "production"
      #for production and staging
      #interactions = Interaction.published.where.not(doi: nil).where(doi_validity: true).map{|i| [i.doi, i.user_id]}.uniq
      interactions = Interaction.published.includes(:related_identifiers).where(related_identifiers: {doi_validity: true}).includes(:datasets).where(datasets: {id: nil}).map{|i| [i.related_identifier.relatedIdentifier, i.user_id]}.uniq
      
    elsif Rails.env = "development"
      interactions = Interaction.active.includes(:related_identifiers).where(related_identifiers: {doi_validity: true}).includes(:datasets).where(datasets: {id: nil}).map{|i| [i.related_identifier.relatedIdentifier, i.user_id]}.uniq
      
    end
    if interactions.present?
      interactions_dois_userids_hash = interactions.inject(Hash.new{ |h,k| h[k]=[] }){ |h,(k,v)| h[k] << v; h }
      summary_statistics = {:success => 0, :failed => 0, :present => 0, :non_singleton => 0}
      puts "IDs Hash: #{interactions_dois_userids_hash}"
        Parallel.each(interactions_dois_userids_hash, :batch_size => 1000, progress: "#{green 'Dataset'} drafting", in_processes: 4) do |doi, userlist|
          dataset = Dataset.where(primary_reference: doi)
          unless dataset.present?
            dataset = Dataset.new(primary_reference: doi)
            dataset.users << User.where(id: userlist)
            dataset.set_primary_identifier

            identifier = dataset.related_identifier
            unless identifier.crossref.present?
              puts "identifier has no crossref"
              identifier.add_crossref
              identifier.save
            end
            if identifier.crossref.present?
              puts "The title of the identifier is #{identifier.crossref["title"]}, its id is: #{identifier.id}"
              dataset.title = dataset.related_identifier.crossref["title"]
              dataset.description = dataset.related_identifier.crossref["abstract"].gsub(/<("[^"]*"|'[^']*'|[^'">])*>/, '') if dataset.related_identifier.crossref["abstract"].present?
              #contributors need to be initialized
              if dataset.related_identifier.crossref["author"].present?
                authors=dataset.related_identifier.crossref["author"].each{|obj| obj.deep_symbolize_keys!}
                dataset.initialize_creator_references(authors)#works
              end
            else
              dataset.title = "Please fill title and authors manually #{dataset.primary_reference}"
            end

            dataset.generate_preliminary_doi

            if dataset.save
              dataset.generate_doi
              dataset.assign_interactions
              dataset.save
              puts "#{cyan Time.now} - #{green "Success!"} Dataset #{dataset.id} was created containing #{dataset.interactions.count} interactions. It belongs to: #{dataset.users.first.full_name}"
              summary_statistics[:success]+=1
            else
              puts "#{cyan Time.now} - #{red "Failed!"} An error occured: #{dataset.errors.full_messages}"
              summary_statistics[:failed]+=1
            end #save check
          else
            puts "#{cyan Time.now} - #{yellow "NO CREATION"} - dataset #{dataset.first.id} already present containing #{blue dataset.first.interactions.count} interactions."
            summary_statistics[:present]+=1
          end #unless dataset already present
        end # each
        begin
          ActiveRecord::Base.connection.reconnect!
        rescue
          ActiveRecord::Base.connection.reconnect!
        end
        puts "#{cyan Time.now} - #{green("Done with drafting datasets from interactions")}"
        puts summary_statistics
      end #presence conditional
      datasets = Dataset.where(state: "draft")
      datasets.find_each(:batch_size => 1000) do |dataset|
        puts "Dataset #{blue dataset.id} is drafted with the DOI:#{dataset.identifier} and contains #{dataset.interactions.count} interactions."
      end
      puts "Current status of datasets at #{cyan Time.now} \ndrafted: #{blue Dataset.drafted.count}; registered: #{yellow Dataset.registered.count}; findable: #{green Dataset.findable.count}"
  end

  desc "Singleton Datasets for existing interactions"
  task draft: :environment do
    puts "Search all singleton (one user) interactions with a valid DOI and bundle them to appropriate datasets."
    #interactions = Interaction.active.where.not(doi: nil).where(doi_validity: true).map{|i| [i.doi, i.user_id]}.uniq #for development
    if Rails.env = "production"
      #for production and staging
      #interactions = Interaction.published.where.not(doi: nil).where(doi_validity: true).map{|i| [i.doi, i.user_id]}.uniq
      interactions = Interaction.published.includes(:related_identifiers).where(related_identifiers: {doi_validity: true}).includes(:datasets).where(datasets: {id: nil}).map{|i| [i.related_identifier.relatedIdentifier, i.user_id]}.uniq
      
    elsif Rails.env = "development"
      interactions = Interaction.active.includes(:related_identifiers).where(related_identifiers: {doi_validity: true}).includes(:datasets).where(datasets: {id: nil}).map{|i| [i.related_identifier.relatedIdentifier, i.user_id]}.uniq
      
    end
    if interactions.present?
      interactions_dois_userids_hash = interactions.inject(Hash.new{ |h,k| h[k]=[] }){ |h,(k,v)| h[k] << v; h }
      summary_statistics = {:success => 0, :failed => 0, :present => 0, :non_singleton => 0}
      puts "IDs Hash: #{interactions_dois_userids_hash}"
        Parallel.each(interactions_dois_userids_hash, :batch_size => 1000, progress: "#{green 'Dataset'} drafting", in_processes: 4) do |doi, userlist|
          if userlist.size == 1
            dataset = Dataset.where(primary_reference: doi)
            unless dataset.present?
              dataset = Dataset.new(primary_reference: doi)
              dataset.users << User.where(id: userlist)
              dataset.set_primary_identifier

              identifier = dataset.related_identifier
              unless identifier.crossref.present?
                puts "identifier has no crossref"
                identifier.add_crossref
                identifier.save
              end
              if identifier.crossref.present?
                puts "The title of the identifier is #{identifier.crossref["title"]}, its id is: #{identifier.id}"
                dataset.title = dataset.related_identifier.crossref["title"]
                dataset.description = dataset.related_identifier.crossref["abstract"].gsub(/<("[^"]*"|'[^']*'|[^'">])*>/, '') if dataset.related_identifier.crossref["abstract"].present?
                if dataset.related_identifier.crossref["author"].present?
                  authors=dataset.related_identifier.crossref["author"].each{|obj| obj.deep_symbolize_keys!}
                  dataset.initialize_creator_references(authors)#works
                end
              else
                dataset.title = "Please fill title and authors manually #{dataset.primary_reference}"
              end

              dataset.generate_preliminary_doi

              if dataset.save
                dataset.generate_doi
                dataset.assign_interactions
                dataset.save
                puts "#{cyan Time.now} - #{green "Success!"} Dataset #{dataset.id} was created containing #{dataset.interactions.count} interactions. It belongs to: #{dataset.users.first.full_name}"
                summary_statistics[:success]+=1
              else
                puts "#{cyan Time.now} - #{red "Failed!"} An error occured: #{dataset.errors.full_messages}"
                summary_statistics[:failed]+=1
              end #save check
            else
              puts "#{cyan Time.now} - #{yellow "NO CREATION"} - dataset #{dataset.first.id} already present containing #{blue dataset.first.interactions.count} interactions."
              summary_statistics[:present]+=1
            end #unless dataset already present
          else
            puts "#{cyan Time.now} - #{red "NO CREATION" }- userlist > 1"
            summary_statistics[:non_singleton]+=1
          end #if singleton
        end # each
        begin
          ActiveRecord::Base.connection.reconnect!
        rescue
          ActiveRecord::Base.connection.reconnect!
        end
        puts "#{cyan Time.now} - #{green("Done with drafting datasets from interactions")}"
        puts summary_statistics
      end #presence conditional
      datasets = Dataset.where(state: "draft")
      datasets.find_each(:batch_size => 1000) do |dataset|
        puts "Dataset #{blue dataset.id} is drafted with the DOI:#{dataset.identifier} and contains #{dataset.interactions.count} interactions."
      end
      puts "Current status of datasets at #{cyan Time.now} \ndrafted: #{blue Dataset.drafted.count}; registered: #{yellow Dataset.registered.count}; findable: #{green Dataset.findable.count}"
  end

  desc "Update datacite jsons"
  task datacite_update: :environment do
    puts "Search all datasets and retrieve datacite json"
    datasets = Dataset.datacite_data_absence
    if datasets.present?
      progressbar = ProgressBar.create(:total => datasets.size, :format => "%a %b\u{15E7}%i %p%% %t", :progress_mark  => ' ', :remainder_mark => "\u{FF65}", :title => "#{green 'Datacite update'}", :starting_at => 0)
      summary_statistics = {:success => 0, :failed => 0}
      Parallel.each(datasets, :batch_size => 1000, progress: "#{green 'Dataset'} datacite update") do |dataset|
        begin
          dataset.save
          puts "#{cyan Time.now} - #{green "Success!"} Dataset #{dataset.id} datacite json was updated, containing #{dataset.interactions.count} interactions. It belongs to: #{dataset.users.first.full_name}"
          summary_statistics[:success]+=1
        rescue => exception
          puts "#{cyan Time.now} - #{reg "Failed!"} Dataset #{dataset.id}, error: #{exception}"
          summary_statistics[:failed]+=1
          
        end 
                
        progressbar.increment
      end #batch loop
      begin
        ActiveRecord::Base.connection.reconnect!
      rescue
        ActiveRecord::Base.connection.reconnect!
      end
      puts "#{cyan Time.now} - #{green("Done with updating the datacite missings.")}"
      puts summary_statistics
    end #presence contitional
    puts "#{cyan Time.now} - #{cyan("No datasets miss datacite data.")}"
  end
  

  desc "Register the drafted datasets"
  task register: :environment do
    puts "Search all datasets in drafted state, run audit, when passed register them."
    datasets = Dataset.drafted.curated
    
    if datasets.present?
      progressbar = ProgressBar.create(:total => datasets.size, :format => "%a %b\u{15E7}%i %p%% %t", :progress_mark  => ' ', :remainder_mark => "\u{FF65}", :title => "#{green 'Interactions Transfer'}", :starting_at => 0)
      summary_statistics = {:success => 0, :failed => 0, :audit_failed => 0}
      Parallel.each(datasets, :batch_size => 1000, progress: "#{green 'Dataset'} registration") do |dataset|
        if dataset.audit? 
          dataset.state = "registered"
          dataset.mere_dataset
          if dataset.save
            puts "#{cyan Time.now} - #{green "Success!"} Dataset #{dataset.id} was registered, containing #{dataset.interactions.count} interactions. It belongs to: #{dataset.users.first.full_name}"
            summary_statistics[:success]+=1
          else
            puts "#{cyan Time.now} - #{red "Failed!"} An error occured: #{dataset.errors.full_messages}"
            summary_statistics[:failed]+=1
          end
        else
          puts "The dataset #{dataset.id} did not pass the audit."
          summary_statistics[:audit_failed]+=1
        end #audit conditional
        progressbar.increment
      end #batch loop
      begin
        ActiveRecord::Base.connection.reconnect!
      rescue
        ActiveRecord::Base.connection.reconnect!
      end
      puts "#{cyan Time.now} - #{green("Done with registering the drafted datasets.")}"
      puts summary_statistics
    end #presence contitional

    datasets = Dataset.where(state: "registered")
    datasets.find_each(:batch_size => 1000) do |dataset|
      puts "Dataset #{blue dataset.id} is registered with the DOI:#{dataset.identifier} and contains #{dataset.interactions.count} interactions. It belongs to: #{dataset.users.first.full_name}"
    end
    puts "Current status of datasets at #{cyan Time.now} \ndrafted: #{blue Dataset.drafted.count}; registered: #{yellow Dataset.registered.count}; findable: #{green Dataset.findable.count}"

  end

  desc "Publish the registered datasets"
  task publish: :environment do
    puts "Search all datasets in registered state and publish them."
    datasets = Dataset.where(state: "registered")
    if datasets.present?
      progressbar = ProgressBar.create(:total => datasets.size, :format => "%a %b\u{15E7}%i %p%% %t", :progress_mark  => ' ', :remainder_mark => "\u{FF65}", :title => "#{green 'Dataset Publication'}", :starting_at => 0)
      summary_statistics = {:success => 0, :failed => 0, :audit_failed => 0}
      Parallel.each(datasets, :batch_size => 1000) do |dataset|
        if dataset.audit?
          dataset.state = "findable"
          if dataset.save
            puts "#{cyan Time.now} - #{green "Success!"} Dataset #{dataset.id} was published, containing #{dataset.interactions.count} interactions. It belongs to: #{dataset.users.first.full_name}"
            summary_statistics[:success]+=1
          else
            puts "#{cyan Time.now} -#{red "Failed!"} An error occured: #{dataset.errors.full_messages}"
            summary_statistics[:failed]+=1
          end
        else
          puts "The dataset #{dataset.id} did not pass the audit."
          summary_statistics[:audit_failed]+=1
        end #audit conditional
        progressbar.increment
      end #batch loop
      begin
        ActiveRecord::Base.connection.reconnect!
      rescue
        ActiveRecord::Base.connection.reconnect!
      end
      puts "#{cyan Time.now} - #{green("Done with pubslisdhing the registered datasets.")}"
      puts summary_statistics #presence conditional
    end
    datasets = Dataset.where(state: "findable")
    datasets.find_each(:batch_size => 1000) do |dataset|
      puts "Dataset #{blue dataset.id} is findable with the DOI:#{dataset.identifier} and contains #{dataset.interactions.count} interactions. It belongs to: #{dataset.users.first.full_name}"
    end
    puts "Current status of datasets at #{cyan Time.now} \ndrafted: #{blue Dataset.drafted.count}; registered: #{yellow Dataset.registered.count}; findable: #{green Dataset.findable.count}"
  end




  desc "Runner"
  task :runall => [:start] do
    # This will run after all those tasks have run
  end

end
