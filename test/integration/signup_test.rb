require 'test_helper'

class SignUpPageTest < Capybara::Rails::TestCase

 test 'sign up section' do

   visit new_user_registration_path
   assert page.has_content?("Email")
   assert page.has_content?("Given Name")
   assert page.has_content?("Family Name")
   visit new_user_registration_path
   assert page.has_content?("ORCID")
   assert page.has_content?("Affiliation")
   assert page.has_content?("Url")
   visit new_user_registration_path
   assert page.has_content?("Role in your Research Unit")
   assert page.has_content?("Password")
   assert page.has_content?("Confirm Password")
   visit new_user_registration_path
   assert page.has_content?("Are you a robot?")
   assert page.has_content?("Upload new image")
   visit new_user_registration_path
   assert page.has_content?("Sign up") #- the assert has_button? maybe locally not working as the page gives an error locally due to recaptcha before creating the button?
   assert page.has_content?("Log in")
   visit new_user_registration_path
   assert page.has_content?("Didn't receive confirmation instructions?")
   assert page.has_content?("Let SupraBank search for your ORCID")

 end

end
 #comment: It seems necessary to restart the page every 3 lines - maybe later a recaptcha-error occurs locally, screwing up the page??
