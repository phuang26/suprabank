class AddIndicesToInteractions < ActiveRecord::Migration
  def change
    change_table :interactions do |t|
      t.index :method
      t.index :assay_type
      t.index :technique
      t.index :binding_constant
      t.index :temperature
      t.index :pH
      t.index :doi
      t.index :itc_deltaH
      t.index :itc_deltaST
      t.index :deltaG
      t.index :citation
      t.index :logKa
      t.index :solvent_system
    end
  end
end
