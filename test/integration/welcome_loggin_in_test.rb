require 'test_helper'

class WelcomeLoggedInTest < Capybara::Rails::TestCase
  include Warden::Test::Helpers

#before (:all) do
  def setup
    @user = users :user_one
    login_as(@user)
  end
#end


#header links
 test 'link new entry' do
   visit root_path
   assert has_link?("Create a new Entry")
   click_link "Create a new Entry"
   assert_current_path new_interaction_path
 end


 test 'link molecules custom molecule' do
   visit root_path
   assert has_link?("Create a custom Molecule")
   click_link "Create a custom Molecule"
   assert_current_path new_molecule_path
 end

 test 'check correct user name' do
   visit root_path
   assert has_link?("normal User")
   assert_not has_link?("Your Group")
   assert_not has_link?("All Group Interactions")
   assert_not has_link?("Mol Tag Cloud")
end

test 'link edit profile' do
  visit root_path
  assert has_link?("Edit Profile")
  click_link "Edit Profile"
  assert_current_path edit_user_registration_path(@user)
end

test 'link view profile' do
  visit root_path
  assert has_link?("View Profile")
  click_link "View Profile"
  assert_current_path user_path(@user)
end

test 'link your interactions' do
  visit root_path
  assert has_link?("Your Interactions")
  click_link "Your Interactions"
  assert_no_current_path root_path
  assert_current_path "/users/"+@user.id.to_s+"/interactions"
end

test 'link log out' do
  visit root_path
  assert has_link?("Log out")
  click_link "Log out"
  assert_current_path destroy_user_session_path
end

#after (:all) do
#  @user= users :admin
#  login_as(@user)
#end


end
