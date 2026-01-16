class ChangeTemperatureInInteractions < ActiveRecord::Migration
  def change
    change_column :interactions, :temperature, :float, default: 25.0, null: false
    add_column :interactions, :is_clone, :boolean, default: false, null: false
  end
end
