class AddGroupAssignConfirmationToUsers < ActiveRecord::Migration
  def change
    unless ActiveRecord::Base.connection.column_exists?(:assignments, :confirmed)
      add_column :assignments, :confirmed, :boolean
    end
    unless ActiveRecord::Base.connection.column_exists?(:assignments, :confirmation_token)
      add_column :assignments, :confirmation_token, :string
    end
    unless ActiveRecord::Base.connection.column_exists?(:assignments, :confirmed_at)
      add_column :assignments, :confirmed_at, :datetime
    end
  end
end
