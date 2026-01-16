class ChangeSubjectInDatasetsTable < ActiveRecord::Migration
  def change
    add_column :datasets, :subjects, :text, array:true
    remove_column :datasets, :subject
  end
end
