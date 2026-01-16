class MoveRelationType < ActiveRecord::Migration
  def change
    remove_column :related_identifiers, :relationType
    add_column :dataset_related_identifiers, :relationType, :integer
  end
end
