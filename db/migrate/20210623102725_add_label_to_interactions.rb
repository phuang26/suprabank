class AddLabelToInteractions < ActiveRecord::Migration
  def change
    add_column :interactions, :label, :text
    add_column :interactions, :varified, :boolean
  end
end
