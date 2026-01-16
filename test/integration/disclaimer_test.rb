require 'test_helper'

class LegalPageTest < Capybara::Rails::TestCase


 test 'page exists' do

  visit legal_path
  assert page.has_content?("Legal")
  assert page.has_content?("External links legal")
  assert has_link?("TermsFeed")
  click_link "TermsFeed"
  assert_no_current_path legal_path
 end

end
