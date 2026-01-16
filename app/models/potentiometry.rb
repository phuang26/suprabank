class Potentiometry < ActiveRecord::Base
  has_many :interactions, as: :in_technique

  def name
    "Potentiometry"
  end

  def abbr
    "POT"
  end

  def olabbr
    "P"
  end


end
