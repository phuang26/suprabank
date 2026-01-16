class CreateDatasetCreators < ActiveRecord::Migration
  def change
    create_table :dataset_creators do |t|
      t.belongs_to :dataset
      t.belongs_to :creator
      t.timestamps null: false
    end
  end
end
