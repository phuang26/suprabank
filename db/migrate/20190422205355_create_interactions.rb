class CreateInteractions < ActiveRecord::Migration
  def change
    create_table :interactions do |t|
      t.string :method
      t.string :assay_type
      t.string :technique
      t.float :binding_constant
      t.float :binding_constant_error
      t.string :binding_constant_unit
      t.belongs_to :molecule
      t.float :lower_molecule_concentration
      t.belongs_to :host,  class: 'Molecule'
      t.float :lower_host_concentration
      t.belongs_to :indicator, class: 'Molecule'
      t.float :lower_indicator_concentration
      t.belongs_to :conjugate, class: 'Molecule'
      t.float :lower_conjugate_concentration
      t.float :temperature
      t.float :pH
      t.string :solvent
      t.string :second_solvent
      t.float :second_solvent_vol_perc
      t.string :third_solvent
      t.float :third_solvent_vol_perc
      t.string :doi
      t.float :itc_deltaH
      t.float :itc_deltaH_error
      t.float :itc_deltaST
      t.float :itc_deltaST_error
      t.float :kin_hg
      t.float :kin_hg_error
      t.string :kin_hg_unit
      t.float :kin_hg
      t.float :kin_hg_error
      t.string :kout_hg_unit
      t.float :icd
      t.float :ct_band
      t.float :lambda_em
      t.float :lambda_ex
      t.float :free_to_bound_FL
      t.string :data
      t.boolean :is_listed

      t.timestamps null: false
    end
  end
end
