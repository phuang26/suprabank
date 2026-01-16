class AddScholarArticleStateToDatasets < ActiveRecord::Migration
  def change
    add_column :datasets, :scholarArticleState, :integer
  end
end
