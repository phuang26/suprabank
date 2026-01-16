require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @group = groups(:group_1)
  end

  test 'group should be valid' do
    assert @group.valid?
  end

  test 'refine_url method' do
    @group.website = 'suprabank.org'
    @group.refine_url
    assert @group.website =~URI::regexp
  end

  test 'refine_url on save' do
    @group.website = 'suprabank.org'
    @group.save
    assert @group.website =~URI::regexp
  end

end
