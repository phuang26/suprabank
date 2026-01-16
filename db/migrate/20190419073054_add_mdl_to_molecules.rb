class AddMdlToMolecules < ActiveRecord::Migration
  def change
    add_column :molecules, :mdl_string, :string
  end
end
