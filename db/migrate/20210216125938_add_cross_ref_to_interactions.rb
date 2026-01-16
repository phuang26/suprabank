class AddCrossRefToInteractions < ActiveRecord::Migration
  def change
    add_column :interactions, :crossref, :json
  end
end
