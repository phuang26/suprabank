class AddErtlToAdditives < ActiveRecord::Migration
  def change
    add_column :additives, :ertl_tpsa, :float
    add_column :additives, :cheng_xlogp3, :float
    add_column :solvents, :ertl_tpsa, :float
    add_column :solvents, :cheng_xlogp3, :float
  end
end
