class AddDeletedAtToInteractions < ActiveRecord::Migration
  def change
    unless ActiveRecord::Base.connection.column_exists?(:interactions, :deleted_at)
      add_column :interactions, :deleted_at, :datetime
    end
  end
end
