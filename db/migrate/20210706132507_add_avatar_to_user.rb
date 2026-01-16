class AddAvatarToUser < ActiveRecord::Migration
  def change
    unless ActiveRecord::Base.connection.column_exists?(:users, :avatar_file_name)
      add_attachment :users, :avatar
    end
  end
end
