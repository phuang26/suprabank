class CreateInteractionRelatedIdentifiers < ActiveRecord::Migration
  def change
    create_table :interaction_related_identifiers do |t|
      t.belongs_to :interaction
      t.belongs_to :related_identifier
      t.timestamps null: false
    end
  end
end
