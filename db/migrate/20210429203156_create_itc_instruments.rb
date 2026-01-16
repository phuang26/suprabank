class CreateItcInstruments < ActiveRecord::Migration
  def change
    create_table :itc_instruments do |t|
      t.text :name
      t.text :alternative_name
      t.text :brand
      t.float :cell_volume
      t.float :syringe_volume
      t.timestamps null: false
    end
  end
end
