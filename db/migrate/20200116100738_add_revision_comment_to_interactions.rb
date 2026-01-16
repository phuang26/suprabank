class AddRevisionCommentToInteractions < ActiveRecord::Migration
  def change
    add_column :interactions, :revision_comment, :string
  end
end
