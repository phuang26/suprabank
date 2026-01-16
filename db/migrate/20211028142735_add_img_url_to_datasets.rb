class AddImgUrlToDatasets < ActiveRecord::Migration
  def change
    add_column :datasets, :img_url, :text
  end
end
