class AddIndicesToMolecules < ActiveRecord::Migration
  def change
    change_table :molecules do |t|
      t.index :inchikey
      t.index :molecular_weight
      t.index :iupac_name
      t.index :display_name
      t.index :cas
      t.index :cano_smiles
      t.index :iso_smiles
      t.index :cid
      t.index :preferred_abbreviation
      t.index :sum_formular
    end
  end
end
