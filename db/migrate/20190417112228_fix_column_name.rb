class FixColumnName < ActiveRecord::Migration
  def change
    rename_column :molecules, :density, :cid
    rename_column :molecules, :exact_molecular_weight, :charge
  end
end
