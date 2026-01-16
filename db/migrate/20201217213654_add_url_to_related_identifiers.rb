class AddUrlToRelatedIdentifiers < ActiveRecord::Migration
  def change
    add_column :related_identifiers, :url, :string
  end
end
