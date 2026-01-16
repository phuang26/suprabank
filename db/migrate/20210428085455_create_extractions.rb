class CreateExtractions < ActiveRecord::Migration
  def change
    create_table :extractions do |t|
      t.text :instrument
      t.timestamps null: false
    end
  end
end
