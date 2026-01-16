require 'csv'

file = "#{Rails.root}/public/data.csv"

interactions = Interaction.active.where(molecule_id: 2)

CSV.open( file, 'w' ) do |writer|
  interactions.each do |s|
    writer << [
      s.id,
      s.assay_type,
      s.technique,
      s.host.display_name,
      s.host.cano_smiles,
      s.molecule.display_name,
      s.molecule.cano_smiles,
      s.indicator.present? ? s.indicator.display_name : nil,
      s.indicator.present? ? s.indicator.cano_smiles : nil,
      s.conjugate.present? ? s.conjugate.display_name : nil,
      s.conjugate.present? ? s.conjugate.cano_smiles : nil,
      s.binding_constant,
      s.deltaG,
      s.temperature,
      s.itc_deltaH.present? ? s.itc_deltaH : nil,
      s.itc_deltaST.present? ? s.itc_deltaST : nil,
      s.pH.present? ? s.pH : nil,
      s.citation.present? ? s.citation : nil,
      s.doi.present? ? s.doi : nil,
      s.additives.first.present? ? s.additives.first.display_name : nil,
      s.additives.second.present? ? s.additives.second.display_name : nil,
      s.additives.third.present? ? s.additives.third.display_name : nil,
      s.solvents.first.present? ? s.solvents.first.display_name : nil,
      s.solvents.second.present? ? s.solvents.second.display_name : nil,
      s.solvents.third.present? ? s.solvents.third.display_name : nil,
      ]
  end
end
