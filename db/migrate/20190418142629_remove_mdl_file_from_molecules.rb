class RemoveMdlFileFromMolecules < ActiveRecord::Migration
  def change
    remove_column :molecules, :molecule_svg_file, :string
  end
end
