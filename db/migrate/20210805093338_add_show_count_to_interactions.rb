class AddShowCountToInteractions < ActiveRecord::Migration
  def change
    add_column :interactions, :show_count, :integer, default: 0
  end
end
