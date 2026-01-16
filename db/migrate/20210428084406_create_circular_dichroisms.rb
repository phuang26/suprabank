class CreateCircularDichroisms < ActiveRecord::Migration
  def change
    create_table :circular_dichroisms do |t|
      t.float :lambda_obs
      t.float :free_to_bound
      t.text :instrument
      t.timestamps null: false
    end
  end
end
