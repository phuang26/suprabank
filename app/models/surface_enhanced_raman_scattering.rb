class SurfaceEnhancedRamanScattering < ActiveRecord::Base
  has_many :interactions, as: :in_technique

  def name
    "Surface Enhanced Raman Scattering"
  end

  def abbr
    "SERS"
  end

  def olabbr
    "S"
  end
end
