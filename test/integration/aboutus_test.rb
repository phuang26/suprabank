require 'test_helper'

class AboutUsPageTest < Capybara::Rails::TestCase


 test 'all elements there' do
  visit about_us_path

  assert page.has_content?("repository for intermolecular interactions")

  assert has_link?("Biedermann Labs")
  click_link "Biedermann Labs"
  assert_no_current_path about_us_path

  visit about_us_path
  assert page.has_content?("Developers")
  assert page.has_content?("Curators")
  assert page.has_content?("Credits")

 end

end
