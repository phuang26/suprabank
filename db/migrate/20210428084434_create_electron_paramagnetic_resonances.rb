class CreateElectronParamagneticResonances < ActiveRecord::Migration
  def change
    create_table :electron_paramagnetic_resonances do |t|
      t.float :magnetic_flux_obs
      t.float :free_to_bound
      t.text :instrument
      t.timestamps null: false
    end
  end
end
