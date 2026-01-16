class AddImageToDatasets < ActiveRecord::Migration
  def self.up
    change_table :datasets do |t|
      t.attachment :img
    end
  end

  def self.down
    remove_attachment :datasets, :img
  end
end
