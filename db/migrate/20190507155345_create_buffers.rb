class CreateBuffers < ActiveRecord::Migration
  def change
    create_table :buffers do |t|
      t.string :name
      t.string :substance_name,                             default: [],                 array: true
      t.float :substance_conc,                             default: [],                 array: true

      t.timestamps null: false
    end
  end
end
