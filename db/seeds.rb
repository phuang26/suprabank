# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# solvents = Solvent.create([
#   {names: ["water", "H2O", "dionized water", "distilled water"]},
#   {names: ["DCM", "CH2Cl2", "dichloromethane", "methylenechlorid"]}
#   ])

techniques = Technique.create([
  {names: ["Absorbance", "ABS", "A"]},
  {names: ["Isothermal Titration Calorimetry", "ITC", "I"]},
  {names: ["Fluorescence", "FL", "F", "Fluorescence Titration"]},
  {names: ["Nuclear Magnetic Resonance", "NMR", "N"]},
  {names: ["Circular Dichroism", "CD", "C"]},
  {names: ["Surface Enhanced Raman Scattering", "SERS", "S"]},
  {names: ["Extraction", "EXT", "E"]},
  {names: ["Potentiometry", "POT", "P"]},
  {names: ["Electron Paramagnetic Resonance", "EPR", "L"]}
  ])

assay_types = AssayType.create([
  {names: ["Direct Binding Assay", "DBA"]},
  {names: ["Competitive Binding Assay", "CBA"]},
  {names: ["Associative Binding Assay", "ABA"]},
  ])

tags = ["typical guest","typical host","aromatic","aliphatic", "dye","amino acid","neurotransmitter","charged","uncharged","herbicide","toxic","terpene","steroid","peptide","protein","carbohydrate"]

  ActsAsTaggableOn::Tag.create(tags.map { |tag| {name: tag} })

# Default users
# Roles: user (0), group_admin (1), admin (2), editor (3)
User.find_or_create_by!(email: 'admin@example.com') do |u|
  u.password              = 'SupraBank123!'
  u.password_confirmation = 'SupraBank123!'
  u.givenName             = 'Admin'
  u.familyName            = 'User'
  u.user_role             = :admin
end

User.find_or_create_by!(email: 'editor@example.com') do |u|
  u.password              = 'SupraBank123!'
  u.password_confirmation = 'SupraBank123!'
  u.givenName             = 'Editor'
  u.familyName            = 'User'
  u.user_role             = :editor
end

User.find_or_create_by!(email: 'user@example.com') do |u|
  u.password              = 'SupraBank123!'
  u.password_confirmation = 'SupraBank123!'
  u.givenName             = 'Regular'
  u.familyName            = 'User'
  u.user_role             = :user
end

User.find_or_create_by!(email: 'group_admin@example.com') do |u|
  u.password              = 'SupraBank123!'
  u.password_confirmation = 'SupraBank123!'
  u.givenName             = 'Group'
  u.familyName            = 'Admin'
  u.user_role             = :group_admin
end



# #moleculms#
# methanol= Molecule.new_from_name("methanol")
# ethanol=Molecule.new_from_name("ethanol")
# n_propanol=Molecule.new_from_name("n-propanol")
# iso_propanol=Molecule.new_from_name("iso-propanol")
#
#
# #interactions#
# Interaction.create(
#   molecule_id: methanol.id, host_id: ethanol.id, assay_type: "DBA",technique: "Fluorescence", binding_constant: 1000, published: false
# )
