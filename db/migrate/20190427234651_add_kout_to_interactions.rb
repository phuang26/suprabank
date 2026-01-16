class AddKoutToInteractions < ActiveRecord::Migration
  def change
    add_column :interactions, :kout_hg, :float
    add_column :interactions, :kout_hg_error, :float
  end
end
