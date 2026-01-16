class ChangeAffiliationInGroups < ActiveRecord::Migration
  def change
    change_table :groups do |t|
      t.rename :affiliation_ror_id, :affiliationIdentifier
    end
  end
end
