require "test_helper"

class InteractionRelatedIdentifierTest < ActiveSupport::TestCase
  def interaction_related_identifier
    @interaction_related_identifier ||= InteractionRelatedIdentifier.new
  end

  def test_valid
    assert interaction_related_identifier.valid?
  end
end
