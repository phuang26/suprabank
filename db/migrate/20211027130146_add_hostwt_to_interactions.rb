class AddHostwtToInteractions < ActiveRecord::Migration
  def change
    add_column :interactions, :host_wt_low, :float
    add_column :interactions, :host_wt_high, :float
  end
end
