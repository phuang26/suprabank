class AddSuspensionToInteraction < ActiveRecord::Migration
  def change
    add_column :interactions, :host_suspension, :boolean
    add_column :interactions, :host_cofactor_wt, :float
  end
end
