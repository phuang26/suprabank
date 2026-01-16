require 'test_helper'

class UserPagesTest < Capybara::Rails::TestCase
  include Warden::Test::Helpers

  #before (:all) do
  def setup
    @user = users :user_one
    login_as(@user)
  end
  #end

 test 'edit profil works' do

   visit edit_user_registration_path(@user)
   assert page.has_content?("Email")
   assert has_selector?("input[value='normaluser@mailinator.com']")
   assert page.has_content?("Given Name")
   assert has_selector?("input[value='normal']")
   assert page.has_content?("Family Name")
   assert has_selector?("input[value='User']")
   assert page.has_content?("Upload new image")
   assert page.has_content?("ORCID")
   assert has_link?("Let SupraBank search for your ORCID")
   assert page.has_content?("Affiliation")
   assert page.has_content?("Url")
   assert page.has_content?("Role in your Research Unit")
   assert has_button?("Change Password")
   click_button("Change Password")
   assert page.has_content?("New Password")
   assert page.has_content?("Confirm Password")
   assert page.has_content?("Current Password")
   assert has_button?("Update")
   assert has_link?("Back")

   click_button("Update")
   assert page.has_content?("Current password can't be blank")
   fill_in 'Current Password', with: '123456'
   click_button("Update")
   assert_current_path root_path

 end

 test 'view profile works' do

    visit user_path(@user)
    assert page.has_content?("normal User", count: 3)
    assert page.has_content?("Personal Information")
    assert page.has_content?("Name")
    assert page.has_content?("Status")
    assert page.has_content?("You are User of the SupraBank. You are an independent researcher.")
    assert has_link?("Create a new Interaction")
    click_link("Create a new Interaction")
    assert_current_path new_interaction_path

    visit user_path(@user)
    assert has_link?("Personal Interactions")
    click_link("Personal Interactions")
    assert_current_path "/users/"+@user.id.to_s+"/interactions"

 end

 test 'your interactions page works' do

    visit "/users/"+@user.id.to_s+"/interactions"
    assert has_link?("Create a new Interaction")
    click_link("Create a new Interaction")
    assert_current_path new_interaction_path

    visit "/users/"+@user.id.to_s+"/interactions"
    assert page.has_content?("Interactions entered by normal User")
    assert page.has_content?("Pending Interactions")
    assert page.has_content?("Accepted")
    assert page.has_content?("Revision requested")
    assert page.has_content?("Submitted")
    assert page.has_content?("Embargoed Interactions")
    assert page.has_content?("Published Interactions")
    assert page.has_content?("Actions / Info", count: 5)
    assert page.has_content?("Molecule", count: 11)
    assert page.has_content?("Partner", count: 10)
    assert page.has_content?("log K", count: 5)
    assert page.has_content?("Medium", count: 5)
    assert page.has_content?("T / ", count: 5)
    assert page.has_content?("ethanol")
    assert page.has_content?("butanol")
 end

 test 'your Curations page works' do

   visit "/users/"+@user.id.to_s+"/revisions"
   assert page.has_content?("Interactions to review")
   assert page.has_content?("Pending Interactions")
   assert page.has_content?("Accepted")
   assert page.has_content?("Revision requested")
   assert page.has_content?("Submitted")
   assert_not page.has_content?("Embargoed Interactions")
   assert_not page.has_content?("Published Interactions")
   assert page.has_content?("Actions / Info", count: 3)
   assert page.has_content?("Molecule", count: 7)
   assert page.has_content?("Partner", count: 6)
   assert page.has_content?("lgK", count: 3)
   assert page.has_content?("DOI", count: 3)
   assert page.has_content?("Reviewer", count: 3)
   assert_not page.has_content?("ethanol")

 end

end
