class AddAffilitionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :affiliation, :string
    add_column :users, :affiliation_ror_id, :string
    add_column :groups, :affiliation_ror_id, :string
  end
end
