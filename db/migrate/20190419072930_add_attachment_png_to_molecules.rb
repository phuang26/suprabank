class AddAttachmentPngToMolecules < ActiveRecord::Migration
  def self.up
    change_table :molecules do |t|
      t.attachment :png
    end
  end

  def self.down
    remove_attachment :molecules, :png
  end
end
