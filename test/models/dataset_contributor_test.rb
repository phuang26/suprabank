require "test_helper"

class DatasetContributorTest < ActiveSupport::TestCase
  def dataset_contributor
    @dataset_contributor ||= DatasetContributor.new
  end

  def test_valid
    assert dataset_contributor.valid?
  end
end
