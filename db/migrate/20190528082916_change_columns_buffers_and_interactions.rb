class ChangeColumnsBuffersAndInteractions < ActiveRecord::Migration
  def change
    add_column :buffers, :conc, :float unless ActiveRecord::Base.connection.column_exists?(:buffers, :conc)
    add_column :interactions, :upper_host_concentration, :float unless ActiveRecord::Base.connection.column_exists?(:interactions, :upper_host_concentration)
    add_column :interactions, :upper_molecule_concentration, :float unless ActiveRecord::Base.connection.column_exists?(:interactions, :upper_molecule_concentration)
    add_column :interactions, :upper_indicator_concentration, :float unless ActiveRecord::Base.connection.column_exists?(:interactions, :upper_indicator_concentration)
    add_column :interactions, :upper_conjugate_concentration, :float unless ActiveRecord::Base.connection.column_exists?(:interactions, :upper_conjugate_concentration)
    add_column :interactions, :binding_range, :string unless ActiveRecord::Base.connection.column_exists?(:interactions, :binding_range)

  end
end
