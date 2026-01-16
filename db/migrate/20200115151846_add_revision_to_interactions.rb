class AddRevisionToInteractions < ActiveRecord::Migration
  def change
    add_column :interactions, :revision, :string, default: 'pending inspection'
  end
end
