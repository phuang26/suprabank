class AddBufferToInteractions < ActiveRecord::Migration
  def change
    add_reference :interactions, :buffer, index: true, foreign_key: true
    add_column :interactions, :deltaG, :float
  end
end
