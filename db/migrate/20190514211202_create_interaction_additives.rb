class CreateInteractionAdditives < ActiveRecord::Migration
  def change
    create_table :interaction_additives do |t|
      t.belongs_to :interaction, index: true
      t.belongs_to :additive, index: true

      t.timestamps null: false
    end
  end
end
