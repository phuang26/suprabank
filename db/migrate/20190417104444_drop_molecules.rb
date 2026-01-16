class DropMolecules < ActiveRecord::Migration
  def change
    if ActiveRecord::Base.connection.table_exists?(:molecules)
      drop_table :molecules
    end
  end
end
