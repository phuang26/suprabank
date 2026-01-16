class CreateFrameworkMolecules < ActiveRecord::Migration
  def change
    create_table :framework_molecules do |t|
      t.belongs_to :molecule
      t.belongs_to :framework
      t.float :si_al_ratio
      t.timestamps null: false
    end
  end
end
