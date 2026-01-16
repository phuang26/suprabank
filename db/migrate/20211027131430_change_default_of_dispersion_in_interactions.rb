class ChangeDefaultOfDispersionInInteractions < ActiveRecord::Migration
  def change
    change_column_default :interactions, :host_suspension, false
  end
end
