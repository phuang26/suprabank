class ChangeUriInDatasets < ActiveRecord::Migration
  def change
    change_column_default :datasets, :alternateIdentifierType, "SupraBank URI"
    change_column_default :datasets, :rights, "Creative Commons Attribution 4.0 International"
    change_column_default :datasets, :rightsURI, "https://creativecommons.org/licenses/by/4.0/deed.en"
    change_column_default :datasets, :rightsIdentifier, "CC-BY-4.0"

  end
end
