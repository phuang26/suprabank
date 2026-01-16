require "test_helper"

class FluorescenceTest < ActiveSupport::TestCase
  def fluorescence
    @fluorescence ||= Fluorescence.new
  end

  def test_valid
    assert fluorescence.valid?
  end
end
