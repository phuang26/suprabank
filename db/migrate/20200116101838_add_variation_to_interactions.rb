class AddVariationToInteractions < ActiveRecord::Migration
  def change
    add_column :interactions, :variation, :string, default: 'molecule'
  end
end
