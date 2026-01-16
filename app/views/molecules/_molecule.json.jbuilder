
json.information do
  json.extract! molecule, :id, :molecule_type, :created_at, :updated_at, :display_name, :preferred_abbreviation
  json.number_of_interactions molecule.interactions_count
  json.url molecule_url(molecule, format: :json)
end
case molecule.molecule_type
when 'compound'
  json.properties do
    json.extract! molecule, :tpsa, :ertl_tpsa, :x_log_p, :cheng_xlogp3, :charge,:h_bond_donor_count,:h_bond_acceptor_count,:bond_stereo_count,:atom_stereo_count,:volume_3d,:sum_formular,:molecular_weight,:complexity,:conformer_count_3d
  end
  json.identifier do
    json.extract! molecule, :display_name, :preferred_abbreviation, :iupac_name, :cas, :cid, :inchikey, :inchistring, :cano_smiles, :iso_smiles
  end
when 'protein'
  json.properties do
    json.extract! molecule, :pdb_id, :pdb_descriptor, :pdb_keywords, :total_structure_weight, :atom_count, :residue_count
  end
  json.identifier do
    json.extract! molecule, :display_name, :preferred_abbreviation, :pdb_title
  end
when 'framework'
  json.properties do
    json.si_al_ratio molecule.framework_molecule.si_al_ratio
    json.counter_ion molecule.framework_molecule&.additive&.display_name
    json.extract! molecule.framework, :name, :code, :iza_url, :crystal_system, :space_group, :unit_cell_a, :unit_cell_b, :unit_cell_c, :unit_cell_alpha, :unit_cell_beta, :unit_cell_gamma, :volume, :rdls, :framework_density, :topological_density, :topological_density_10, :ring_sizes, :channel_dimensionality, :max_d_sphere_included, :max_d_sphere_diffuse_a, :max_d_sphere_diffuse_b, :max_d_sphere_diffuse_c, :accessible_volume
  end
  json.identifier do
    json.extract! molecule.framework, :name, :code, :iza_url
  end
end


