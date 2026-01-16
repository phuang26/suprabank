class CreateFrameworkMoleculeAdditives < ActiveRecord::Migration
  def change
    create_table :framework_molecule_additives do |t|
      t.belongs_to :additive
      t.belongs_to :framework_molecule
      t.timestamps null: false
    end
  end
end
