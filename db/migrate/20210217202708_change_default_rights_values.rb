class ChangeDefaultRightsValues < ActiveRecord::Migration
  def change
    change_column_default :datasets, :rightsIdentifier, "cc-by-4.0"
    change_column_default :datasets, :rights, "Creative Commons Attribution 4.0 International"
    change_column_default :datasets, :rightsURI, "https://creativecommons.org/licenses/by/4.0/legalcode"
  end
end
