class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.string :affiliation
      t.string  :department
      t.string  :city
      t.string  :website
      t.timestamps null: false
    end
  end
end
