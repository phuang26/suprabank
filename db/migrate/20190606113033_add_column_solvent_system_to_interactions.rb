class AddColumnSolventSystemToInteractions < ActiveRecord::Migration
  def change
    add_column :interactions, :solvent_system, :string
  end
end
