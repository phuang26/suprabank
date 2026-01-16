class CreateTechniques < ActiveRecord::Migration
  def change
    create_table :techniques do |t|
      t.string   :names, default: [], array: true

      t.timestamps null: false
    end
  end
end
