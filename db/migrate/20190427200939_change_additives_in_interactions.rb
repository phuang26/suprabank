class ChangeAdditivesInInteractions < ActiveRecord::Migration
  def change
    add_reference :interactions, :additive, index: true, array: true, default: []
  end
end
