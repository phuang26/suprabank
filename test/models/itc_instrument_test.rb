require "test_helper"

class ItcInstrumentTest < ActiveSupport::TestCase
  def itc_instrument
    @itc_instrument ||= ItcInstrument.new
  end

  def test_valid
    assert itc_instrument.valid?
  end
end
