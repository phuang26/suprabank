class CreateBufferAdditives < ActiveRecord::Migration
  def change
    create_table :buffer_additives do |t|
      t.belongs_to :additive, index: true, foreign_key: true
      t.belongs_to :buffer, index: true, foreign_key: true
      t.float :concentration
      t.timestamps null: false
    end
  end
end
