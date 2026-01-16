class AddIndicatorwtToInteractions < ActiveRecord::Migration
  def change
    add_column :interactions, :host_indicator_wt, :float
  end
end
