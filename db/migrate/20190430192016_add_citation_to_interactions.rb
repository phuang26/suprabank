class AddCitationToInteractions < ActiveRecord::Migration
  def change
    add_column :interactions, :citation, :string
  end
end
