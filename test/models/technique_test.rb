require 'test_helper'

class TechniqueTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @technique = Technique.new
  end

  test  "technique should be valid" do
    assert @technique.valid?
  end
end
