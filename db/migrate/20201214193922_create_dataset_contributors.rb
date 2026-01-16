class CreateDatasetContributors < ActiveRecord::Migration
  def change
    create_table :dataset_contributors do |t|
      t.belongs_to :dataset
      t.belongs_to :contributor
      t.timestamps null: false
    end
  end
end
