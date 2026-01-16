class IsothermalTitrationCalorimetry < ActiveRecord::Base
  has_many :interactions, as: :in_technique

  def name
    "Isothermal Titration Calorimetry"
  end

  def abbr
    "ITC"
  end

  def olabbr
    "I"
  end
end

# 
# create_table "isothermal_titration_calorimetries", force: :cascade do |t|
#   t.float    "cell_volume"
#   t.float    "injection_volume"
#   t.float    "injection_number"
#   t.float    "syringe_concentration"
#   t.text     "instrument"
#   t.datetime "created_at",            null: false
#   t.datetime "updated_at",            null: false
# end
