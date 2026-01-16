# The class is named after the policy to be tested.
class MoleculePolicyTest < PolicyAssertions::Test

  # Test that the Article model allows index and show
  # for any site visitor. nil is passed in for the user.
  def test_index_and_show
    assert_permit nil, Molecule
  end

  # Test that a site staff member is allowed access
  # to new and create
  def test_new_and_create
    assert_permit users(:user_one), Molecule
  end

  # Test that this user cannot delete this article
  def test_destroy
    refute_permit users(:user_one), molecules(:molecule_one)
    assert_permit users(:admin), molecules(:molecule_one)
    refute_permit users(:editor), molecules(:molecule_one)
    refute_permit users(:group_admin), molecules(:molecule_one)

    # Alternate method name
  end

  # Test a permission by passing in an array instead of
  # defining it in the method name
  def test_name_is_not_a_permission
    refute_permit nil, Molecule, 'create?', 'new?'
  end


end
