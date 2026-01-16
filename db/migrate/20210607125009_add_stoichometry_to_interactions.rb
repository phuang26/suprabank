class AddStoichometryToInteractions < ActiveRecord::Migration
  def change
    add_column :interactions, :stoichometry_molecule, :float, default: 1
    add_column :interactions, :stoichometry_host, :float, default: 1
    add_column :interactions, :stoichometry_indicator, :float, default: 1
    add_column :interactions, :stoichometry_conjugate, :float, default: 1
  end
end
