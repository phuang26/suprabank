class AddNameToCooperators < ActiveRecord::Migration
  def change
    add_column :creators, :name, :string
    add_column :contributors, :name, :string
  end
end
