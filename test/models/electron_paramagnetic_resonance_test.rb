require "test_helper"

class ElectronParamagneticResonanceTest < ActiveSupport::TestCase
  def electron_paramagnetic_resonance
    @electron_paramagnetic_resonance ||= ElectronParamagneticResonance.new
  end

  def test_valid
    assert electron_paramagnetic_resonance.valid?
  end
end
