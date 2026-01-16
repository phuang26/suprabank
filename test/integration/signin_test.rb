require 'test_helper'

class SignInPageTest < Capybara::Rails::TestCase

 test 'all elements exist' do

  visit new_user_session_path
  assert page.has_content?("Email")
  assert page.has_field?('Email', type: 'email')
  assert page.has_content?("Password")
  assert page.has_field?('Password', type: 'password')
  assert page.has_content?("Remember me")

  assert has_button?("Log in")
  click_button("Log in")
  assert page.has_content?("Invalid Email or password.")

  assert has_link?("Sign up")
  click_link("Sign up")
  assert_current_path new_user_registration_path

  visit new_user_session_path
  fill_in "Email", with: "normaluser@mailinator.com"
  fill_in "Password", with: "123456"
  click_button("Log in")
  assert_current_path root_path

  visit new_user_session_path
  assert_current_path root_path
  assert page.has_content?("You are already signed in.")

end

test 'forgot password section' do

  visit new_user_session_path
  assert has_link?("Forgot your password?")
  click_link("Forgot your password?")
  assert_current_path new_user_password_path

  assert page.has_content?("Email")
  assert page.has_field?('Email', type: 'email')
  assert has_button?("Send me reset password instructions")
  click_button("Send me reset password instructions")
  assert page.has_content?("Email can't be blank")

  assert has_link?("Log in")
  click_link("Log in")
  assert_current_path new_user_session_path

  visit new_user_password_path
  assert has_link?("Sign up")
  click_link("Sign up")
  assert_current_path new_user_registration_path

  visit new_user_password_path
  assert has_link?("Didn't receive confirmation instructions?")
  click_link("Didn't receive confirmation instructions?")
  assert_current_path new_user_confirmation_path

end

test 'confirmation instructions section' do

  visit new_user_session_path
  assert has_link?("Didn't receive confirmation instructions?")
  click_link("Didn't receive confirmation instructions?")
  assert_current_path new_user_confirmation_path

  assert page.has_content?("Email")
  assert page.has_field?('Email', type: 'email')
  assert has_button?("Resend confirmation instructions")
  click_button("Resend confirmation instructions")
  assert page.has_content?("Email can't be blank")

  assert page.has_content?("Log in")
  click_link("Log in")
  assert_current_path new_user_session_path

  visit new_user_confirmation_path
  assert has_link?("Sign up")
  click_link("Sign up")
  assert_current_path new_user_registration_path

  visit new_user_confirmation_path
  assert has_link?("Forgot your password?")
  click_link("Forgot your password?")
  assert_current_path new_user_password_path
end

end
