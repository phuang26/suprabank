class CreateSolvents < ActiveRecord::Migration
  def change
    create_table :solvents do |t|
      t.string   "inchikey"
      t.string   "inchistring"
      t.float    "molecular_weight"
      t.float    "volume_3d"
      t.float    "tpsa"
      t.float    "complexity"
      t.string   "sum_formular"
      t.string   "names",                            default: [],                 array: true
      t.string   "iupac_name"
      t.string   "display_name"
      t.string   "cas"
      t.float    "conformer_count_3d"
      t.float    "bond_stereo_count"
      t.float    "atom_stereo_count"
      t.float    "h_bond_donor_count"
      t.float    "h_bond_acceptor_count"
      t.float    "x_log_p"
      t.float    "charge"
      t.string   "cano_smiles"
      t.string   "iso_smiles"
      t.string   "fingerprint_2d"
      t.boolean  "is_partial",                       default: false, null: false
      t.datetime "created_at",                                       null: false
      t.datetime "updated_at",                                       null: false
      t.datetime "deleted_at"
      t.string   "pubchem_link"
      t.integer  "cid"
      t.string   "svg_file_name"
      t.string   "svg_content_type"
      t.integer  "svg_file_size",          limit: 8
      t.datetime "svg_updated_at"
      t.string   "png_file_name"
      t.string   "png_content_type"
      t.integer  "png_file_size",          limit: 8
      t.datetime "png_updated_at"
      t.string   "mdl_string"
      t.string   "preferred_abbreviation"
    end
  end
end
