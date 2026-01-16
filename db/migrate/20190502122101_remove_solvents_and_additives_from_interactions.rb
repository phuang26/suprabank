class RemoveSolventsAndAdditivesFromInteractions < ActiveRecord::Migration
  def change
    remove_column :interactions, :solvent_id
    remove_column :interactions, :additive_id
  end
end
