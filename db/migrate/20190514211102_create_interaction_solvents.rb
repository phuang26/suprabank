class CreateInteractionSolvents < ActiveRecord::Migration
  def change
    create_table :interaction_solvents do |t|
      t.belongs_to :interaction, index: true 
      t.belongs_to :solvent, index: true

      t.timestamps null: false
    end
  end
end
