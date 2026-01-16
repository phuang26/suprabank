class ChangeColumnSolventInInteractions < ActiveRecord::Migration
  def change
    remove_column :interactions, :solvent, :string
    remove_column :interactions, :second_solvent, :string
    add_reference :interactions, :solvent, index: true, array: true, default: []
    #add_foreign_key :interactions, :solvents

  end
end
