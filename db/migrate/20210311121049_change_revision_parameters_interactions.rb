class ChangeRevisionParametersInteractions < ActiveRecord::Migration
  def change
    unless ActiveRecord::Base.connection.column_exists?(:interactions, :reviewer_id)
      add_column :interactions, :reviewer_id, :integer
    end
    change_column :interactions, :revision_comment, :text
  end
end
