require "test_helper"

class PotentiometryTest < ActiveSupport::TestCase
  def potentiometry
    @potentiometry ||= Potentiometry.new
  end

  def test_valid
    assert potentiometry.valid?
  end
end
