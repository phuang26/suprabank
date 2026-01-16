class AddPositionsToIsothermalTitrationCalorimetry < ActiveRecord::Migration
  def change
    add_column :isothermal_titration_calorimetries, :host_cell, :boolean
    add_column :isothermal_titration_calorimetries, :molecule_cell, :boolean
    add_column :isothermal_titration_calorimetries, :indicator_cell, :boolean
    add_column :isothermal_titration_calorimetries, :conjugate_cell, :boolean
  end
end
