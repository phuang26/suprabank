class Absorbance < ActiveRecord::Base
  has_many :interactions, as: :in_technique


  def name
    "Absorbance"
  end

  def abbr
    "ABS"
  end

  def olabbr
    "A"
  end

end
