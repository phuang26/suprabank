class ChangeDatasetColumns < ActiveRecord::Migration
  def change
    change_column_default :datasets, :language, "english"
    change_column_default :datasets, :state, "draft"
    remove_column :datasets, :publicationYear
  end
end
