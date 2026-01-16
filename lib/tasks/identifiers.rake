require "colors"
include Colors

namespace :identifiers do
  desc "Initializer"
  task start: :environment do
    puts "You are running all setups, that will take few minutes, get a coffee!"
  end



  desc "Check validity of related identifiers"
  task doi: :environment do
    puts "Go through all RelatedIdentifiers that do not possess doi_validity and check it."
    Benchmark.bm do |x|
      x.report {
        relidents = RelatedIdentifier.where(doi_validity: nil)
        if relidents.present?
          Parallel.each(relidents, :batch_size => 1000, progress: "DOI validation") do |relident|
            begin
              relident.check_doi_validity
              if relident.save
                puts "#{Time.now} - #{green "Success!"} RelatedIdentifier #{relident.id} was audited and its doi validity is: #{relident.doi_validity}."
              else
                puts "#{Time.now} - #{red "Failed!"} An error occured: #{relident.errors.full_messages}."
              end #save check
            rescue => e
              puts e
            end #Exception
          end #RelatedIdentifier loop
          begin
            ActiveRecord::Base.connection.reconnect!
          rescue
            ActiveRecord::Base.connection.reconnect!
          end
        else
          puts "#{cyan Time.now} - All RelatedIdentifiers are validated for their dois."
        end #presence
      }
    end #Benchmark
    RelatedIdentifier.connection.reconnect!
  end #task doi

  desc "Update Image Link and description"
  task toc: :environment do
    puts "Retrieve toc images and descriptions by crawling publishers meta data, crossref should be present"
    RelatedIdentifier.connection.reconnect!
    relidents = RelatedIdentifier.where.not(crossref: nil).where(doi_validity: true).where(toc_url: nil)
    if relidents.present?
      progressbar = ProgressBar.create(:total => relidents.size, :format => "%a %b\u{15E7}%i %p%% %t", :progress_mark  => ' ', :remainder_mark => "\u{FF65}", :title => "#{green 'Interactions Transfer'}", :starting_at => 0)
      relidents.find_each(:batch_size => 1000) do |relident|
        begin
          relident.meta_data_retriever
          if relident.save
            puts "#{cyan Time.now} -#{green "Success!"} RelatedIdentifier #{relident.id} obtained ToC URL." if relident.toc_url.present?
          else
            puts "#{cyan Time.now} -#{red "Failed!"} An error occured: #{relident.errors.full_messages} on RelatedIdentifier #{relident.id} "
          end #save check
        rescue => e
          puts e
        end #Exception
        progressbar.increment
      end #RelatedIdentifier loop
    end #presence conditional
  end

  desc "Add crossref to related identifiers"
  task crossref: :environment do
    puts "Go through all RelatedIdentifiers that do not possess a crossref and add it"
    RelatedIdentifier.connection.reconnect!
    relidents = RelatedIdentifier.where(crossref: nil, doi_validity: true)
    if relidents.present?
      Parallel.each(relidents, :batch_size => 1000, progress: "#{green 'CrossRef'} addition") do |relident|
        begin
          relident.add_crossref
          if relident.save
            puts "#{cyan Time.now} -#{green "Success!"} RelatedIdentifier #{relident.id} obtained crossref."
          else
            puts "#{cyan Time.now} -#{red "Failed!"} An error occured: #{relident.errors.full_messages} on RelatedIdentifier #{relident.id} "
          end #save check
        rescue => e
          puts e
        end #Exception
      end #RelatedIdentifier loop
      begin
        ActiveRecord::Base.connection.reconnect!
      rescue
        ActiveRecord::Base.connection.reconnect!
      end
    else
      puts "#{cyan Time.now} - All RelatedIdentifiers possess crossref files."
    end #presence
    RelatedIdentifier.connection.reconnect!
  end #task crossref

  desc "Clip bibtex to related identifiers"
  task bibtex: :environment do
    puts "Go through all RelatedIdentifiers that do not possess a bibtex and clip it"
    RelatedIdentifier.connection.reconnect!
    relidents = RelatedIdentifier.where(bibtex_file_name: nil, doi_validity: true)
    if relidents.present?
      Parallel.each(relidents, :batch_size => 1000, progress: "#{green 'Bibtex'} clipping") do |relident|
        begin
          relident.clip_bibtex
          if relident.save
            puts "#{cyan Time.now} - #{green "Success!"} RelatedIdentifier #{relident.id} obtained bibtex."
          else
            puts "#{cyan Time.now} - #{red "Failed!"} An error occured: #{relident.errors.full_messages} on RelatedIdentifier #{relident.id} "
          end #save check
        rescue => e
          puts e
        end #Exception
      end #RelatedIdentifier loop
      begin
        ActiveRecord::Base.connection.reconnect!
      rescue
        ActiveRecord::Base.connection.reconnect!
      end
    else
      puts "#{cyan Time.now} - All RelatedIdentifiers possess bibtex files."
    end #presence
    RelatedIdentifier.connection.reconnect!
  end #task crossref

  desc "Transfer DOIs from interactions "
  task transfer: :environment do
    puts "Find interactions without related identifier and set the identifier."
    interactions = Interaction.active.includes(:related_identifiers).where(related_identifiers: {id: nil}).where.not(doi:nil)
    puts "Interactions class: #{interactions.class}, interactions_size: #{interactions.size}"
    if interactions.present?
      progressbar = ProgressBar.create(:format => "%a %b\u{15E7}%i %p%% %t", :progress_mark  => ' ', :remainder_mark => "\u{FF65}", :title => "#{green 'Interactions Transfer'}", :starting_at => 0, :total => interactions.size)
      interactions.find_each(:batch_size => 1000) do |int|
        #DO NOT run in parallel, will lead to unwanted dublicates
        begin
          puts "inside batch loop Interaction class: #{int.class}, interactions_id: #{int.id}"
          int.set_identifier
        rescue => e
          puts e
        end #Exception
        progressbar.increment
      end #RelatedIdentifier loop
    else
      puts "#{cyan Time.now} - All Interactions (#{blue Interaction.count}) are associated to RelatedIdentifiers (#{blue RelatedIdentifier.count}) via the InteractionRelatedIdentifiers (#{blue InteractionRelatedIdentifier.count})."
    end #presence
    puts "summary #{{"RelatedIdentifiers": RelatedIdentifier.count, "with crossref": RelatedIdentifier.where.not(crossref:nil).count, "with bibtex": RelatedIdentifier.where.not(bibtex_file_name:nil).count}}"
  end #task transfer


  desc "Note 1"
  task :note1 => :environment do
    # This will run after all those tasks have run
    puts "You are running multiple steps for the RelatedIdentifier model the steps: Auditing, Addition of CrossRef and Bibtex on EXISTING related identifiers."
  end



  desc "Existing"
  task :existing => [:note1, :doi, :crossref, :toc, :bibtex] do
    # This will run after all those tasks have run
  end

  desc "Run all tasks"
  task :run_all => [:transfer, :existing] do
    # This will run after all those tasks have run
  end



end
