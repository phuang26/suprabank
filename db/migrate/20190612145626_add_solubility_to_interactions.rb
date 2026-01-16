class AddSolubilityToInteractions < ActiveRecord::Migration
  def change
    add_column :interactions, :solubility, :float
  end
end
