class DropTableSolvents < ActiveRecord::Migration
  def change
    if ActiveRecord::Base.connection.table_exists?(:solvents)
      drop_table :solvents
    end
  end
end
