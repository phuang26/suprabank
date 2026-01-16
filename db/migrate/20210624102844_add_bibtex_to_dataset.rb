class AddBibtexToDataset < ActiveRecord::Migration
  def change
    add_attachment :datasets, :bibtex
  end
end
