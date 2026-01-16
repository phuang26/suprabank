class AddInteractionIdToInteractions < ActiveRecord::Migration
  def change
    add_column :interactions, :linked_interaction, :integer
  end
end
