require "test_helper"

class AbsorbanceTest < ActiveSupport::TestCase
  def absorbance
    @absorbance ||= Absorbance.new
  end

  def test_valid
    assert absorbance.valid?
  end
end
