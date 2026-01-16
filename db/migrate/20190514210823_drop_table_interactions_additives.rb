class DropTableInteractionsAdditives < ActiveRecord::Migration
  def change
    drop_table :interactions_solvents
    drop_table :interactions_additives
  end
end
