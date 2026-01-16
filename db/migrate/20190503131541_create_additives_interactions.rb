class CreateAdditivesInteractions < ActiveRecord::Migration
  def change
    create_table :additives_interactions do |t|
      t.belongs_to :interaction, index: true
      t.belongs_to :additive, index: true
    end
  end
end
