require "test_helper"

class CircularDichroismTest < ActiveSupport::TestCase
  def circular_dichroism
    @circular_dichroism ||= CircularDichroism.new
  end

  def test_valid
    assert circular_dichroism.valid?
  end
end
