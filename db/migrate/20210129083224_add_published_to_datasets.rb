class AddPublishedToDatasets < ActiveRecord::Migration
  def change
    add_column :datasets, :published, :integer
    drop_table :appointments
  end
end
