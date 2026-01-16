class CreateSurfaceEnhancedRamanScatterings < ActiveRecord::Migration
  def change
    create_table :surface_enhanced_raman_scatterings do |t|
      t.float :nu_obs
      t.float :free_to_bound
      t.text :instrument
      t.timestamps null: false
    end
  end
end
