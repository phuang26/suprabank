class AddLabelToDatasets < ActiveRecord::Migration
  def change
    add_column :datasets, :label, :text
    add_column :datasets, :varified, :boolean
    add_column :datasets, :primary_reference, :text
  end
end
