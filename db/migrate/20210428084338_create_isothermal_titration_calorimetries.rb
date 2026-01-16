class CreateIsothermalTitrationCalorimetries < ActiveRecord::Migration
  def change
    create_table :isothermal_titration_calorimetries do |t|
      t.float :cell_volume
      t.float :cell_concentration
      t.float :injection_volume
      t.float :initial_injection_volume
      t.float :injection_number
      t.float :syringe_concentration
      t.float :syringe_volume
      t.text :instrument
      t.timestamps null: false
    end
  end
end
