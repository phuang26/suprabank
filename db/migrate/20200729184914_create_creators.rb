class CreateCreators < ActiveRecord::Migration
  def change
    create_table :creators do |t|
      t.text  :creatorName
      t.text  :nameType
      t.text  :givenName
      t.text  :familyName
      t.text  :nameIdentifier
      t.text  :nameIdentifierScheme, default: "ORCID"
      t.text  :schemeURI, default: "https://orcid.org"
      t.text  :affiliation
      t.text  :affiliationIdentifier
      t.text  :affiliationIdentifierScheme, default:"ROR"
      t.text  :SchemeURI, default:"https://ror.org/"

      t.timestamps null: false
    end
  end
end
