class AddDeltaGErrorToInteractions < ActiveRecord::Migration
  def change
    add_column :interactions, :deltaG_error, :float
  end
end
