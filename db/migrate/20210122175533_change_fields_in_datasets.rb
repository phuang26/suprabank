class ChangeFieldsInDatasets < ActiveRecord::Migration
  def change
    add_column :datasets, :published, :date
    add_column :datasets, :registered, :date
    change_column_default :datasets, :rightsIdentifier, "CC BY-SA 4.0"
    change_column_default :datasets, :rights, "Creative Commons Attribution-ShareAlike 4.0 International"
  end
end
