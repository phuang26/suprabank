class AddlogKaErrorToInteractions < ActiveRecord::Migration
  def change
    add_column :interactions, :logka_error, :float
  end
end
