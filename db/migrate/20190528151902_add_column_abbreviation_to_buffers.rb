class AddColumnAbbreviationToBuffers < ActiveRecord::Migration
  def change
    add_column :buffers, :abbreviation, :string
  end
end
