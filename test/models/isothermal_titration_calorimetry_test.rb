require "test_helper"

class IsothermalTitrationCalorimetryTest < ActiveSupport::TestCase
  def isothermal_titration_calorimetry
    @isothermal_titration_calorimetry ||= IsothermalTitrationCalorimetry.new
  end

  def test_valid
    assert isothermal_titration_calorimetry.valid?
  end
end
