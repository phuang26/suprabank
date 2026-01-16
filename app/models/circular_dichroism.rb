class CircularDichroism < ActiveRecord::Base
  has_many :interactions, as: :in_technique

  def name
    "Circular Dichroism"
  end

  def abbr
    "CD"
  end

  def olabbr
    "C"
  end
end
