class AddCitationToRelatedIdentifier < ActiveRecord::Migration
  def change
    add_column :related_identifiers, :citation, :text
  end
end
