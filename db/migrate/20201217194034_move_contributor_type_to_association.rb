class MoveContributorTypeToAssociation < ActiveRecord::Migration
  def change
    remove_column :contributors, :contributorType
    add_column :dataset_contributors, :contributorType, :integer
  end
end
