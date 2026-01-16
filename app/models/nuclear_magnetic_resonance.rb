class NuclearMagneticResonance < ActiveRecord::Base
  has_many :interactions, as: :in_technique

  def name
    "Nuclear Magnetic Resonance"
  end

  def abbr
    "NMR"
  end

  def olabbr
    "N"
  end
end
