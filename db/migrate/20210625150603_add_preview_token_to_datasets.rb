class AddPreviewTokenToDatasets < ActiveRecord::Migration
  def change
    add_column :datasets, :preview_token, :string
    add_column :datasets, :citation, :text
  end
end
