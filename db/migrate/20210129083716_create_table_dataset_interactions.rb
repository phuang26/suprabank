class CreateTableDatasetInteractions < ActiveRecord::Migration
  def change
    create_table :dataset_interactions do |t|
      t.belongs_to :dataset
      t.belongs_to :interaction
      t.timestamps
    end
  end
end
