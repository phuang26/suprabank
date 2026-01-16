class AddPhToBuffers < ActiveRecord::Migration
  def change
    add_column :buffers, :pH, :float
    remove_column :buffers, :substance_name
    remove_column :buffers, :substance_conc
  end
end
