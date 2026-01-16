class Extraction < ActiveRecord::Base
  has_many :interactions, as: :in_technique

  def name
    "Extraction"
  end

  def abbr
    "EXT"
  end

  def olabbr
    "E"
  end
end
