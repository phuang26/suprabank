require 'test_helper'

class ContributorPageTest < Capybara::Rails::TestCase


 test 'graphic and list there' do
  visit groups_path

  assert page.has_content?("Contributing Groups")

  assert has_selector?("#groups_country_map")

  assert page.has_content?("Institution")

 end

end
