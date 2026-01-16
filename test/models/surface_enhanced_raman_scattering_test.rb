require "test_helper"

class SurfaceEnhancedRamanScatteringTest < ActiveSupport::TestCase
  def surface_enhanced_raman_scattering
    @surface_enhanced_raman_scattering ||= SurfaceEnhancedRamanScattering.new
  end

  def test_valid
    assert surface_enhanced_raman_scattering.valid?
  end
end
