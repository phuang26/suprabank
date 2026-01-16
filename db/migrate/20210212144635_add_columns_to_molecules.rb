class AddColumnsToMolecules < ActiveRecord::Migration
  def change
    add_column :molecules, :pdb_id, :string
    add_column :molecules, :total_structure_weight, :float
    add_column :molecules, :atom_count, :integer
    add_column :molecules, :residue_count, :integer
    add_column :molecules, :pdb_descriptor, :text
    add_column :molecules, :pdb_title, :text
    add_column :molecules, :pdb_keywords, :text
    add_column :molecules, :molecule_type, :integer, default: 0
    add_column :molecules, :cheng_xlogp3, :float
    add_column :molecules, :ertl_tpsa, :float

  end
end
