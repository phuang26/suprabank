class CreateDatasetUsers < ActiveRecord::Migration
  def change
    create_table :dataset_users do |t|
      t.belongs_to :dataset
      t.belongs_to :user
      t.timestamps null: false
    end
  end
end
