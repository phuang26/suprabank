class AddPngurlToMolecules < ActiveRecord::Migration
  def change
    add_column :molecules, :png_url, :text
    add_column :solvents, :png_url, :text
    add_column :additives, :png_url, :text
  end
end
