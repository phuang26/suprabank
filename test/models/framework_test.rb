require "test_helper"

class FrameworkTest < ActiveSupport::TestCase
  def framework
    @framework ||= Framework.new
  end

  def test_valid
    assert framework.valid?
  end
end
