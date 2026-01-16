namespace :interactor do

  desc "Initializer"
  task start: :environment do
    puts "You are running all setups, that will take few minutes, get a coffee!"
  end

  desc "Create some Users"
  task users: :environment do
    puts "Three normal users will be created with userX@gmail.com and 123456 as pw"
    unless User.find_by(:email => "normaluser@mailinator.com").present?
      User.create!({:email => "normaluser@mailinator.com", :password => "123456", :password_confirmation => "123456", :confirmed_at=>Time.now, :role => 'independent' })
    end
    unless User.find_by(:email => "user2@gmail.com").present?
      User.create!({:email => "user2@gmail.com", :password => "123456", :password_confirmation => "123456", :confirmed_at=>Time.now, :role => 'independent' })
    end
    unless User.find_by(:email => "user3@gmail.com").present?
      User.create!({:email => "user3@gmail.com", :password => "123456", :password_confirmation => "123456", :confirmed_at=>Time.now, :role => 'independent' })
    end
  end

  desc "TODO"
  task molecules: :environment do
    puts "Some standard molecules will be created"
    unless Molecule.new_from_cid(702)=="exist"
      Molecule.new_from_name("ethanol")
    end
      @ethanol=Molecule.find_by(cid: 702)

    unless Molecule.new_from_cid(887)=="exist"
      Molecule.new_from_name("methanol")
    end
      @methanol=Molecule.find_by(cid: 887)

    unless Molecule.new_from_cid(1031)=="exist"
      Molecule.new_from_name("n-propanol")
    end
      @n_propanol=Molecule.find_by(cid: 1031)

    unless Molecule.new_from_cid(3776)=="exist"
      Molecule.new_from_name("iso-propanol")
    end
      @iso_propanol=Molecule.find_by(cid: 3776)

  end

  desc "TODO"
  task interactions: :environment do
    puts "Some standard interactions will be created"
    Interaction.create(user:User.find_by(:email => "user1@gmail.com"), molecule: @ethanol, host: @methanol, binding_constant: 1000, logKa:3, doi: "10.10210/125405", binding_constant_unit: "M-1", published: true,  assay_type: "Competitive Binding Assay", indicator: @iso_propanol, technique: "Absorbance")
    Interaction.create(user:User.find_by(:email => "user1@gmail.com"),molecule: @methanol, host: @methanol, binding_constant: 1000, logKa:3, doi: "10.10210/125405", binding_constant_unit: "M-1",published: true,  assay_type: "Direct Binding Assay", technique: "Fluorescence")
    Interaction.create(user:User.find_by(:email => "user1@gmail.com"),molecule: @n_propanol, host: @methanol, binding_constant: 1000, logKa:3, doi: "10.10210/125405", binding_constant_unit: "M-1",published: true,  assay_type: "Associative Binding Assay", conjugate: @iso_propanol, technique: "Nuclear Magnetic Resonance")
    Interaction.create(user:User.find_by(:email => "user1@gmail.com"),molecule: @ethanol, host: @n_propanol, binding_constant: 1000, logKa:3, doi: "10.10210/125405", binding_constant_unit: "M-1",published: true,  assay_type: "Competitive Binding Assay", indicator: @ethanol, technique: "Isothermal Titration Calorimetry")
    Interaction.create(user:User.find_by(:email => "user1@gmail.com"), molecule: @ethanol, host: @methanol, binding_constant: 2000, logKa:Math.log10(2000), doi: "10.10210/125405", binding_constant_unit: "M-1",published: true,  assay_type: "Competitive Binding Assay", indicator: @ethanol, technique: "Absorbance")
    Interaction.create(user:User.find_by(:email => "user1@gmail.com"),molecule: @methanol, host: @methanol, binding_constant: 6438, logKa:Math.log10(6438), doi: "10.10210/125405", binding_constant_unit: "M-1",published: true,  assay_type: "Direct Binding Assay", technique: "Fluorescence")
    Interaction.create(user:User.find_by(:email => "user1@gmail.com"),molecule: @n_propanol, host: @methanol, binding_constant: 3120, logKa:Math.log10(3120), doi: "10.10210/125405", binding_constant_unit: "M-1",published: true,  assay_type: "Associative Binding Assay", conjugate: @ethanol, technique: "Nuclear Magnetic Resonance")
    Interaction.create(user:User.find_by(:email => "user1@gmail.com"),molecule: @ethanol, host: @n_propanol, binding_constant: 421, logKa:Math.log10(421), doi: "10.10210/125405", binding_constant_unit: "M-1",published: true,  assay_type: "Competitive Binding Assay", indicator: @methanol, technique: "Isothermal Titration Calorimetry")
  end

  desc "TODO"
  task solvents: :environment do
    puts "Some standard solvents will be created"
    unless Solvent.new_from_cid(702)=="exist"
      Solvent.new_from_name("ethanol")
    end
      @sol_ethanol=Solvent.find_by(cid: 702)

    unless Solvent.new_from_cid(887)=="exist"
      Solvent.new_from_name("methanol")
    end
      @sol_methanol=Solvent.find_by(cid: 887)

    unless Solvent.new_from_cid(1031)=="exist"
      Solvent.new_from_name("n-propanol")
    end
      @sol_n_propanol=Solvent.find_by(cid: 1031)

    unless Solvent.new_from_cid(3776)=="exist"
      Solvent.new_from_name("iso-propanol")
    end
      @sol_iso_propanol=Solvent.find_by(cid: 3776)
  end

  desc "TODO"
  task additives: :environment do
    puts "Some standard additives will be created"
    unless Additive.new_from_cid(4873)=="exist"
      Additive.new_from_name("potassium chloride")
    end
      @add_kcl=Additive.find_by(cid: 4873)

    unless Additive.new_from_cid(311)=="exist"
      Additive.new_from_name("Citric acid")
    end
      @add_citric=Additive.find_by(cid: 311)

    unless Additive.new_from_cid(517045)=="exist"
      Additive.new_from_name("Sodium acetate")
    end
      @add_naac=Additive.find_by(cid: 517045)

    unless Additive.new_from_cid(14798)=="exist"
      Additive.new_from_name("Sodium hydroxide")
    end
      @add_naoh=Additive.find_by(cid: 14798)
  end



  desc "Runner"
  task :runall => [:start,:users, :molecules, :solvents, :additives, :interactions] do
    # This will run after all those tasks have run
  end

end
