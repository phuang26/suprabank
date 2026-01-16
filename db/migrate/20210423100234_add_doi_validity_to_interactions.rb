class AddDoiValidityToInteractions < ActiveRecord::Migration
  def change
    unless ActiveRecord::Base.connection.column_exists?(:interactions, :doi_validity)
      add_column :interactions, :doi_validity, :boolean
    end
  end

  def down

  end
end
