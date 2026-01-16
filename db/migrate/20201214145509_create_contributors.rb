class CreateContributors < ActiveRecord::Migration
  def change
    create_table :contributors do |t|
      t.integer  :contributorType, index: true
      t.text  :contributorName, index: true
      t.text  :nameType
      t.text  :givenName, index: true
      t.text  :familyName, index: true
      t.text  :nameIdentifier
      t.text  :nameIdentifierScheme, default: "ORCID"
      t.text  :schemeURI, default: "https://orcid.org"
      t.text  :affiliation, index: true
      t.text  :affiliationIdentifier, index: true
      t.text  :affiliationIdentifierScheme, default:"ROR"
      t.text  :SchemeURI, default:"https://ror.org/"
      t.timestamps null: false
    end
  end
end
