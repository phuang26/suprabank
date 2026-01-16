require 'csv'

file = "#{Rails.root}/public/data.csv"

interactions = Interaction.active.where(molecule_id: 1)

CSV.open( file, 'w' ) do |writer|
  interactions.each do |s|
    writer << [s.id, s.molecule.display_name, s.binding_constant]
  end
end
