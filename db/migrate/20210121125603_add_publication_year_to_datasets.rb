class AddPublicationYearToDatasets < ActiveRecord::Migration
  def change
    add_column :datasets, :publicationYear, :integer
  end
end
