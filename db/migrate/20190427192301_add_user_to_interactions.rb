class AddUserToInteractions < ActiveRecord::Migration
  def change
    add_reference :interactions, :user, index: true
    add_foreign_key :interactions, :users
    add_column :interactions, :logKa, :float
  end
end
