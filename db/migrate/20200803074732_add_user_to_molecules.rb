class AddUserToMolecules < ActiveRecord::Migration
  def change
    add_reference :molecules, :user, index: true
    add_foreign_key :molecules, :users
    
  end
end
