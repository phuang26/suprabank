class AddAbbToMolecules < ActiveRecord::Migration
  def change
    add_column :molecules, :preferred_abbreviation, :string
  end
end
