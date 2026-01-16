class Fluorescence < ActiveRecord::Base
include Technology
has_many :interactions, as: :in_technique

def name
  "Fluroescence"
end

def abbr
  "FL"
end

def olabbr
  "F"
end




end




  # create_table "fluorescences", force: :cascade do |t|
  #   t.float    "lambda_ex"
  #   t.float    "lambda_em"
  #   t.float    "free_to_bound"
  #   t.text     "instrument"
  #   t.datetime "created_at",    null: false
  #   t.datetime "updated_at",    null: false
  # end
