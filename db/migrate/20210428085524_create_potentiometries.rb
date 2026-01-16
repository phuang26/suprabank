class CreatePotentiometries < ActiveRecord::Migration
  def change
    create_table :potentiometries do |t|
      t.text :instrument
      t.timestamps null: false
    end
  end
end
