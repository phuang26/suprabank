class AddAttachmentSvgToMolecules < ActiveRecord::Migration
  def self.up
    change_table :molecules do |t|
      t.attachment :svg
    end
  end

  def self.down
    remove_attachment :molecules, :svg
  end
end
