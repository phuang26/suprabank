class AddIndexToInteractions < ActiveRecord::Migration
  def change
    add_index :interactions, :molecule_id
    add_index :interactions, :host_id
    add_index :interactions, :indicator_id
    add_index :interactions, :conjugate_id
  end
end
