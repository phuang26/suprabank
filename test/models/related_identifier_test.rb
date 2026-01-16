require "test_helper"

class RelatedIdentifierTest < ActiveSupport::TestCase

  def setup
    @related_identifier_one = related_identifiers :one
  end

  def test_valid
    assert @related_identifier_one.valid?
  end
end
