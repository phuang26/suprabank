class CreateNuclearMagneticResonances < ActiveRecord::Migration
  def change
    create_table :nuclear_magnetic_resonances do |t|
      t.float :shift_bound
      t.float :shift_unbound
      t.float :delta_shift
      t.text :nucleus
      t.text :instrument
      t.timestamps null: false
    end
  end
end
