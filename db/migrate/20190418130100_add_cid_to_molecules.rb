class AddCidToMolecules < ActiveRecord::Migration
  def change
    add_column :molecules, :cid, :integer
  end
end
