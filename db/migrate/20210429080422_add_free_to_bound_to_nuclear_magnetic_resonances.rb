class AddFreeToBoundToNuclearMagneticResonances < ActiveRecord::Migration
  def change
    add_column :nuclear_magnetic_resonances, :free_to_bound, :float
  end
end
