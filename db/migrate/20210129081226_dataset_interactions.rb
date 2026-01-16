# frozen_string_literal: true

class DatasetInteractions < ActiveRecord::Migration
  def change
    create_table :appointments do |t|
      t.belongs_to :dataset
      t.belongs_to :interaction
      t.timestamps
    end

    if ActiveRecord::Base.connection.column_exists?(:datasets, :published)
      remove_column :datasets, :published
    end
    
    if ActiveRecord::Base.connection.column_exists?(:interactions, :dataset_id)
      remove_column :interactions, :dataset_id
    end

  end
end
