class AddCountryToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :country, :string
  end
end
