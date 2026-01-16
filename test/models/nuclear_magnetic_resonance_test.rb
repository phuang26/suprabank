require "test_helper"

class NuclearMagneticResonanceTest < ActiveSupport::TestCase
  def nuclear_magnetic_resonance
    @nuclear_magnetic_resonance ||= NuclearMagneticResonance.new
  end

  def test_valid
    assert nuclear_magnetic_resonance.valid?
  end
end
