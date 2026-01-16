class CreateAssayTypes < ActiveRecord::Migration
  def change
    create_table :assay_types do |t|
      t.string   :names, default: [], array: true

      t.timestamps null: false
    end
  end
end
