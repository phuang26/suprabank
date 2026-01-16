class AddInteractionsCountToMolecules < ActiveRecord::Migration
  def change
    add_column :molecules, :interactions_count, :integer
    add_column :solvents, :interactions_count, :integer
    add_column :buffers, :interactions_count, :integer
    add_column :additives, :interactions_count, :integer
  end
end
