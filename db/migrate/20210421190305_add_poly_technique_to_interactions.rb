class AddPolyTechniqueToInteractions < ActiveRecord::Migration
  def change
    add_column :interactions, :in_technique_id, :integer
    add_column :interactions, :in_technique_type, :string
  end
end
