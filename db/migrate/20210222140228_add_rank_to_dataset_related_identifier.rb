class AddRankToDatasetRelatedIdentifier < ActiveRecord::Migration
  def change
    add_column :dataset_related_identifiers, :rank, :integer, default: 1
  end
end
