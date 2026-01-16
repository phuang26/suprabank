class AddEmbargoToInteractions < ActiveRecord::Migration
  def change
    unless ActiveRecord::Base.connection.column_exists?(:interactions, :embargo)
      add_column :interactions, :embargo, :boolean
    end
  end
end
