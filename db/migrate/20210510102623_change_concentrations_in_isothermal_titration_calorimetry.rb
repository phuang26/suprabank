class ChangeConcentrationsInIsothermalTitrationCalorimetry < ActiveRecord::Migration
  def change
    add_column :isothermal_titration_calorimetries, :concentration_indicator, :float
    add_column :isothermal_titration_calorimetries, :concentration_conjugate, :float
    rename_column  :isothermal_titration_calorimetries, :cell_concentration, :concentration_molecule
    rename_column  :isothermal_titration_calorimetries, :syringe_concentration, :concentration_host
  end
end
