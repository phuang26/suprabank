class AddPublishedToInteractions < ActiveRecord::Migration
  def change
    add_column :interactions, :published, :boolean, default: false
  end
end
