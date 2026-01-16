class CreateMolecules < ActiveRecord::Migration
  def change
    create_table :molecules do |t|
      t.string   "inchikey"
      t.string   "inchistring"
      t.float    "density",                           default: 0.0
      t.float    "molecular_weight"
      t.float    "volume_3d"
      t.float    "tpsa"
      t.float    "complexity"
      t.string   "sum_formular"
      t.string   "names",                             default: [],                 array: true
      t.string   "iupac_name"
      t.string   "display_name"
      t.string   "cas"
      t.float    "conformer_count_3d"
      t.float    "bond_stereo_count"
      t.float    "atom_stereo_count"
      t.float    "h_bond_donor_count"
      t.float    "h_bond_acceptor_count"
      t.float    "x_log_p"
      t.binary   "molecule_svg_file"
      t.float    "exact_molecular_weight"
      t.string   "cano_smiles"
      t.string   "iso_smiles"
      t.string   "fingerprint_2d"
      t.boolean  "is_partial",                        default: false, null: false
      t.string   "molecule_svg_file"
      t.timestamps null: false
      t.datetime "deleted_at"
    end
  end
end
