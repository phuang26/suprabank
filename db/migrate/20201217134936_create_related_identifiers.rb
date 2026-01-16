class CreateRelatedIdentifiers < ActiveRecord::Migration
  def change
    create_table :related_identifiers do |t|
      t.text     "relatedIdentifier"
      t.text     "relatedIdentifierType",   default: "DOI"
      t.text     "relationType",            default: "IsSupplementTo"
      t.timestamps null: false
    end


    create_table :dataset_related_identifiers do |t|
      t.belongs_to :dataset
      t.belongs_to :related_identifier
      t.timestamps null: false
    end


    remove_column :datasets, :relatedIdentifier
    remove_column :datasets, :relatedIdentifierType
    remove_column :datasets, :relationType

  end
end
