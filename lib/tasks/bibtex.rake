namespace :bibtex do

  desc "Initializer"
  task start: :environment do
    puts "This is the bibtex rake utility of SupraBank"
  end

  desc "Add single Bibtex Clip"
  task single: :environment do
    puts "This will clip_bibtex to Interaction 180"
    begin
      interaction = Interaction.find(180)
    rescue ActiveRecord::RecordNotFound => e
      puts "Found interaction"
    end

    if interaction.present?
      interaction.clip_bibtex
      interaction.save
      puts "#{interaction.id} was update. Done!"
      puts "Time: #{Time.now}"
    else
      puts "could not find Interaction but task run"
      puts "Time: #{Time.now}"
    end

  end

  desc "Add all Bibtexes"
  task bibtexes: :environment do
    puts "This will clip_bibtex to all Interactions not having it yet"
    interactions = Interaction.active.where(bibtex_file_name: nil)
    if interactions.present?
      interactions.find_each(:batch_size => 1000) do |int|
        begin
          int.convert_doi
          int.clip_bibtex
          int.save
          puts "Bibtex of #{int.id} was updated. Done!"
          puts "Time: #{Time.now}"
        rescue => e
          puts e
        end
      end
    else
      puts "All Interactions possess bibtex files"
      puts "Time: #{Time.now}"
    end
  end

  desc "Add all CrossRefs"
  task crossrefs: :environment do
    puts "This will add_crossref to all Interactions not having it yet"
    interactions = Interaction.active.where(crossref: nil)
    if interactions.present?
      interactions.find_each(:batch_size => 1000) do |int|
        begin
          int.convert_doi
          int.add_crossref
          int.save
          puts "#{int.id} was updated. Done!"
          puts "Time: #{Time.now}"
        rescue => e
          puts e
        end
      end
    else
      puts "All Interactions possess crossref files"
      puts "Time: #{Time.now}"
    end
  end


  desc "Runner"
  task :runall => [:start, :bibtexes, :crossrefs] do
    # This will run after all those tasks have run
  end


end
