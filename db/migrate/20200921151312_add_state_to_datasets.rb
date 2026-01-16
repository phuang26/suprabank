class AddStateToDatasets < ActiveRecord::Migration
  def change
    add_column :datasets, :state, :string, default:"Draft"
  end
end
