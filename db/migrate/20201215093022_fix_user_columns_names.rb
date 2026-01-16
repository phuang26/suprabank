class FixUserColumnsNames < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.rename :first_name, :givenName
      t.rename :last_name, :familyName
      t.rename :orcid, :nameIdentifier
    end
  end
end
