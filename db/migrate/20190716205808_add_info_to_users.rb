class AddInfoToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :group, index: true, foreign_key: true
    add_column :users, :url, :string
    add_column :users, :moderator, :boolean, default: false
    add_column :users, :role, :string
  end
end
