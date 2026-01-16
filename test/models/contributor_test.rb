require "test_helper"

class ContributorTest < ActiveSupport::TestCase
  def contributor
    @contributor ||= Contributor.new
  end

  def test_valid
    assert contributor.valid?
  end
end
