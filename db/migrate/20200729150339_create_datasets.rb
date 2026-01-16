class CreateDatasets < ActiveRecord::Migration
  def change
    create_table :datasets do |t|
      t.string :identifier
      t.string :identifierType, default: "DOI"
      t.text  :title
      t.string :publisher, default: "SupraBank"
      t.date  :publicationYear
      t.text :resourceType, default: "Interaction Data"
      t.text :resourceTypeGeneral, default: "Dataset"
      t.text :subject
      t.text :language, default: "English"
      t.text :description
      t.text :descriptionType, default:"Abstract"
      t.text :relatedIdentifier
      t.text :relatedIdentifierType, default: "DOI"
      t.text :relationType, default: "IsSupplementTo"
      t.text :size
      t.text :format, default: "text/html"
      t.text :alternateIdentifier
      t.text :alternateIdentifierType, default:"SupraBank URL"
      t.text :rights, default: "Creative Commons Attribution 3.0 Germany License"
      t.text :rightsURI, default: "https://creativecommons.org/licenses/by/3.0/de/deed.en"
      t.text :rightsIdentifier, default: "CC-BY-3.0"
      t.text :rightsIdentifierScheme, default: "SPDX"
      t.text :schemeURI, default:"https://spdx.org/licenses/"
      t.date :available_at
      t.timestamps null: false
    end
  end
end
