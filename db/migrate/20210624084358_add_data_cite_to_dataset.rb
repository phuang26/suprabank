class AddDataCiteToDataset < ActiveRecord::Migration
  def change
    add_column :datasets, :datacite, :json
  end
end
