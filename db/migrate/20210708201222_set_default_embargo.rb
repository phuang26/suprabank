class SetDefaultEmbargo < ActiveRecord::Migration
  def change
    change_column_default :interactions, :embargo, true
  end
end
