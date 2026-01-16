class AddDesiredGroupToAssignments < ActiveRecord::Migration
  def change
    unless ActiveRecord::Base.connection.column_exists?(:assignments, :desired_group_id)
      add_column :assignments, :desired_group_id, :integer, index: true
    end
  end
end
