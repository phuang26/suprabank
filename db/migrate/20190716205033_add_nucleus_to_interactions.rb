class AddNucleusToInteractions < ActiveRecord::Migration
  def change
    add_column :interactions, :nucleus, :string
    add_column :interactions, :delta_S, :float

  end
end
