class AddLinkToMolecules < ActiveRecord::Migration
  def change
     add_column :molecules, :pubchem_link, :string 
  end
end
