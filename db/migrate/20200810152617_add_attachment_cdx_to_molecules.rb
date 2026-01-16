class AddAttachmentCdxToMolecules < ActiveRecord::Migration
  def self.up
    change_table :molecules do |t|
      t.attachment :cdx
    end
  end

  def self.down
    remove_attachment :molecules, :cdx
  end
end
