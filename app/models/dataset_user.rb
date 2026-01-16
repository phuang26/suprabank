class DatasetUser < ActiveRecord::Base
  belongs_to :dataset
  belongs_to :user
end
