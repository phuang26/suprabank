require 'test_helper'

class AssayTypeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @assay_type = AssayType.new
  end

  test  "assay_type should be valid" do
    assert @assay_type.valid?
  end
end
