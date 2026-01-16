class AddCounterToDatasets < ActiveRecord::Migration
  def change
    add_column :datasets, :show_count, :integer, default: 0
    add_column :datasets, :view_count, :integer, default: 0
    add_column :datasets, :download_count, :integer, default: 0
    add_column :datasets, :citation_count, :integer, default: 0
    add_column :datasets, :citation_export_count, :integer, default: 0
  end
end
