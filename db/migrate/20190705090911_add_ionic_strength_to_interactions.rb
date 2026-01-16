class AddIonicStrengthToInteractions < ActiveRecord::Migration
  def change
    add_column :interactions, :ionic_strength, :float
  end
end
