class AddConcentrationToInteractionAdditives < ActiveRecord::Migration
  def change
    add_column :interaction_additives, :concentration, :float
    add_column :interaction_solvents, :volume_percent, :float
  end
end
