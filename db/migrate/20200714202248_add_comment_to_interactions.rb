class AddCommentToInteractions < ActiveRecord::Migration
  def change
    add_column :interactions, :comment, :text, limit:100
  end
end
