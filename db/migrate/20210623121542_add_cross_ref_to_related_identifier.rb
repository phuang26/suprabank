class AddCrossRefToRelatedIdentifier < ActiveRecord::Migration
  def change
    add_column :related_identifiers, :crossref, :json
    add_column :related_identifiers, :doi_validity, :boolean
    add_attachment :related_identifiers, :bibtex
  end
end
