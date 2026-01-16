class CreateFluorescences < ActiveRecord::Migration
  def change
    create_table :fluorescences do |t|
      t.float :lambda_ex
      t.float :lambda_em
      t.float :free_to_bound
      t.text :instrument

      t.timestamps null: false
    end
  end
end
