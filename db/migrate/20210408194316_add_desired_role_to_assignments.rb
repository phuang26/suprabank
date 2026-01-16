class AddDesiredRoleToAssignments < ActiveRecord::Migration
  def change
    unless ActiveRecord::Base.connection.column_exists?(:assignments, :desired_role)
      add_column :assignments, :desired_role, :string
    end
  end
end
