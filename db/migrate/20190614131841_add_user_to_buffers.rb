class AddUserToBuffers < ActiveRecord::Migration
  def change
    add_reference :buffers, :user, index: true
    add_foreign_key :buffers, :users
  end
end
