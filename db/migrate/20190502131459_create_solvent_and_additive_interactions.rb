class CreateSolventAndAdditiveInteractions < ActiveRecord::Migration
  def change
    create_table :interactions_solvents do |t|
      t.belongs_to :interaction, index: true
      t.belongs_to :solvent, index: true
    end
    create_table :interactions_additives do |t|
      t.belongs_to :interaction, index: true
      t.belongs_to :additive, index: true
    end



  end
end
