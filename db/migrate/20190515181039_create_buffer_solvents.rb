class CreateBufferSolvents < ActiveRecord::Migration
  def change
    create_table :buffer_solvents do |t|
      t.belongs_to :solvent, index: true, foreign_key: true
      t.belongs_to :buffer, index: true, foreign_key: true
      t.float :volume_percent
      t.timestamps null: false
    end
  end
end
