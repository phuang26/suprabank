class AddPartsToInteractions < ActiveRecord::Migration
  def change
    remove_column :interactions, :second_solvent_vol_perc
    remove_column :interactions, :third_solvent
    remove_column :interactions, :third_solvent_vol_perc
    add_column :interactions, :vol_perc, :float, array:true, default:[1]
    add_column :interactions, :additive_conc, :float, array:true, default:[]
  end
end
