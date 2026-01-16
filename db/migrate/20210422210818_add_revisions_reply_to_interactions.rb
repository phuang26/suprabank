class AddRevisionsReplyToInteractions < ActiveRecord::Migration
  def change
    unless ActiveRecord::Base.connection.column_exists?(:interactions, :revisions_reply)
      add_column :interactions, :revisions_reply, :text
    end
  end

  def down

  end
end
