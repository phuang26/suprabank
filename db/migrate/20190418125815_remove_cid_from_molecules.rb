class RemoveCidFromMolecules < ActiveRecord::Migration
  def change
    remove_column :molecules, :cid
  end
end
