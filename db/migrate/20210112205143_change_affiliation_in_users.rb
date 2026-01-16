class ChangeAffiliationInUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.rename :affiliation_ror_id, :affiliationIdentifier
    end
  end
end
