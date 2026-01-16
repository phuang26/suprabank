class AddSourceofconcentrationToBuffers < ActiveRecord::Migration
  def change
    add_column :buffers, :sourceofconcentration, :string
  end
end
