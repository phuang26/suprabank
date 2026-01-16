class AddSizeCountToDatasets < ActiveRecord::Migration
  def change
    add_column :datasets, :size_count, :integer
  end
end
