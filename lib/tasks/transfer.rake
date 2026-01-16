require 'technology'
include Technology
namespace :transfer do


  desc "Initializer"
  task start: :environment do
    puts "You are running all setups, that will take few minutes, get a coffee!"
  end


  desc "Transfer Fluorescence Technique"
  task fluorescence: :environment do
    interactions = Interaction.where(in_technique_type: nil).where(technique: "Fluorescence")
    puts "#{interactions.count} entries will be processed"
    interactions.each do |i|
      in_technique_params = {lambda_em: i.lambda_em, lambda_ex: i.lambda_ex, free_to_bound: i.free_to_bound_FL}
      technique_model = i.technique.singularize.delete(' ').classify.constantize #
      in_technique = technique_model.where(generate_query_from_params(in_technique_params)).first_or_create(in_technique_params)
      i.in_technique = in_technique
      i.save
      puts "#{Time.now} — Updated Interaction #{i.id}!"
    end
  end


  desc "Transfer Absorbance Technique"
  task absorbance: :environment do
    interactions = Interaction.where(in_technique_type: nil).where(technique: "Absorbance")
    puts "#{interactions.count} entries will be processed"
    interactions.each do |i|
      in_technique_params = {lambda_obs: i.lambda_ex, free_to_bound: i.free_to_bound_FL}
      technique_model = i.technique.singularize.delete(' ').classify.constantize #
      in_technique = technique_model.where(generate_query_from_params(in_technique_params)).first_or_create(in_technique_params)
      i.in_technique = in_technique
      i.save
      puts "#{Time.now} — Updated Interaction #{i.id}!"
    end
  end

  desc "Transfer CD Technique"
  task circular: :environment do
    interactions = Interaction.where(in_technique_type: nil).where(technique: "Circular Dichroism")
    puts "#{interactions.count} entries will be processed"
    interactions.each do |i|
      in_technique_params = {lambda_obs: i.lambda_ex, free_to_bound: i.free_to_bound_FL}
      technique_model = i.technique.singularize.delete(' ').classify.constantize #
      in_technique = technique_model.where(generate_query_from_params(in_technique_params)).first_or_create(in_technique_params)
      i.in_technique = in_technique
      i.save
      puts "#{Time.now} — Updated Interaction #{i.id}!"
    end
  end

  desc "Transfer EPR Technique"
  task electron: :environment do
    interactions = Interaction.where(in_technique_type: nil).where(technique: "Electron Paramagnetic Resonance")
    puts "#{interactions.count} entries will be processed"
    interactions.each do |i|
      in_technique_params = {magnetic_flux_obs: i.lambda_ex, free_to_bound: i.free_to_bound_FL}
      technique_model = i.technique.singularize.delete(' ').classify.constantize #
      in_technique = technique_model.where(generate_query_from_params(in_technique_params)).first_or_create(in_technique_params)
      i.in_technique = in_technique
      i.save
      puts "#{Time.now} — Updated Interaction #{i.id}!"
    end
  end

  desc "Transfer NMR Technique"
  task nuclear: :environment do
    interactions = Interaction.where(in_technique_type: nil).where(technique: "Nuclear Magnetic Resonance")
    puts "#{interactions.count} entries will be processed"
    interactions.each do |i|
      in_technique_params = {delta_shift: i.nmrshift, nucleus: i.nucleus, free_to_bound: i.free_to_bound_FL}
      technique_model = i.technique.singularize.delete(' ').classify.constantize #
      in_technique = technique_model.where(generate_query_from_params(in_technique_params)).first_or_create(in_technique_params)
      i.in_technique = in_technique
      i.save
      puts "#{Time.now} — Updated Interaction #{i.id}!"
    end
  end


  desc "Transfer SERS Technique"
  task sers: :environment do
    interactions = Interaction.where(in_technique_type: nil).where(technique: "Surface Enhanced Raman Scattering")
    puts "#{interactions.count} entries will be processed"
    interactions.each do |i|
      in_technique_params = {nu_obs: i.lambda_ex, free_to_bound: i.free_to_bound_FL}
      technique_model = i.technique.singularize.delete(' ').classify.constantize #
      in_technique = technique_model.where(generate_query_from_params(in_technique_params)).first_or_create(in_technique_params)
      i.in_technique = in_technique
      i.save
      puts "#{Time.now} — Updated Interaction #{i.id}!"
    end
  end

  desc "Transfer Extraction, ITC and Potentiometry Technique"
  task extraction: :environment do
    interactions = Interaction.where(in_technique_type: nil).where(technique: ["Extraction", "Potentiometry", "Isothermal Titration Calorimetry"])
    puts "#{interactions.count} entries will be processed"
    interactions.each do |i|
      technique_model = i.technique.singularize.delete(' ').classify.constantize #
      in_technique = technique_model.create
      i.in_technique = in_technique
      i.save
      puts "#{Time.now} — Updated Interaction #{i.id}!"
    end
  end

  desc "Runner"
  task :runall => [:fluorescence, :absorbance, :extraction, :sers, :nuclear, :electron, :circular] do
    # This will run after all those tasks have run
  end

end
