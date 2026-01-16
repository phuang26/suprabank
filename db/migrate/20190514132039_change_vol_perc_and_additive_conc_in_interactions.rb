class ChangeVolPercAndAdditiveConcInInteractions < ActiveRecord::Migration
  def change
    change_column_default :interactions, :vol_perc, nil
    change_column_default :interactions, :additive_conc, nil
    add_column :interactions, :nmrshift, :float
  end
end
