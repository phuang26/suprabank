class AddUserIndices < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.index :givenName
      t.index :familyName
      t.index :nameIdentifier
      t.index :affiliation
      t.index :affiliation_ror_id
    end
  end
end
