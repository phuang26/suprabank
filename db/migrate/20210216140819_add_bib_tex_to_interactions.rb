class AddBibTexToInteractions < ActiveRecord::Migration
  def self.up
    change_table :interactions do |t|
      t.attachment :bibtex
    end
  end

  def self.down
    remove_attachment :interactions, :bibtex
  end
end
