class ElectronParamagneticResonance < ActiveRecord::Base
  has_many :interactions, as: :in_technique

  def name
    "Electron Paramagnetic Resonance"
  end

  def abbr
    "EPR"
  end

  def olabbr
    "L"
  end
end
