class ChangeDefault < ActiveRecord::Migration
  def change
    change_column_default :datasets, :subjects, nil
  end
end
