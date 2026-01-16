class ChangeDefaultVolPercAndAdditiveConcInInteractions < ActiveRecord::Migration
  def change
    change_column_default :interactions, :vol_perc, nil
    change_column_default :interactions, :additive_conc, nil
  end
end
