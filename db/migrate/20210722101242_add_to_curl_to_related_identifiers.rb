class AddToCurlToRelatedIdentifiers < ActiveRecord::Migration
  def change
    add_column :related_identifiers, :toc_url, :text
  end
end
