require "test_helper"

class ExtractionTest < ActiveSupport::TestCase
  def extraction
    @extraction ||= Extraction.new
  end

  def test_valid
    assert extraction.valid?
  end
end
