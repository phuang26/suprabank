require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = users(:user_one)
  end

  test  "user should be valid" do
    assert @user.valid?
  end

  test 'refinement of URL method' do
    @user.url = 'suprabank.org'
    @user.refine_url
    assert @user.url =~ URI::regexp
  end

  test 'refinement of URL upon save' do
    @user.url = 'suprabank.org'
    @user.save
    assert @user.url =~ URI::regexp
  end

  test 'full_name Anonymous' do
    @user.givenName = nil
    @user.familyName = nil
    assert 'Anonymous'==@user.full_name
  end

  test 'full_name real' do
    @user.givenName = 'Supra'
    @user.familyName = 'Bank'
    assert 'Supra Bank'==@user.full_name
  end

end
