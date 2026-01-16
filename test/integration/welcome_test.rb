require 'test_helper'

class WelcomePageTest < Capybara::Rails::TestCase

  def setup
    @one = molecules :molecule_one
    @two = molecules :molecule_two
  end


#header links
test 'link logo and latest entries' do
  visit root_path

  assert has_selector?("#logo")
  assert has_link?(href: root_path)

  assert has_link?("Latest Entries")
  click_link "Latest Entries"
  assert_current_path interactions_path
end

test 'link search' do
  visit root_path
  assert has_link?("Search")
  click_link "Search"
  assert_current_path intsearch_interactions_path
end

test 'link advanced search' do
  visit root_path
  assert has_link?("Advanced Search")
  click_link "Advanced Search"
  assert_current_path advanced_search_interactions_path
end

test 'link new entry' do
  visit root_path
  assert has_link?("Create a new Entry")
  click_link "Create a new Entry"
  assert_current_path new_user_session_path
end

test 'link molecules search' do
  visit root_path
  assert has_link?("Search by Names or Tags")
  click_link "Search by Names or Tags"
  assert_current_path molecules_path
end

test 'link molecules chemeditor' do
  visit root_path
  assert has_link?("Search using Chemical Editor")
  click_link "Search using Chemical Editor"
  assert_current_path chemeditor_molecules_path
end

test 'link molecules custom molecule' do
  visit root_path
  assert has_link?("Create a custom Molecule")
  click_link "Create a custom Molecule"
  assert_current_path new_user_session_path
end

test 'link buffers' do
  visit root_path
  assert has_link?("Buffers")
  click_link "Buffers"
  assert_current_path buffers_path
end

test 'link solvents' do
  visit root_path
  assert has_link?("Solvents")
  click_link "Solvents"
  assert_current_path solvents_path
end

test 'link additives' do
  visit root_path
  assert has_link?("Additives")
  click_link "Additives"
  assert_current_path additives_path
end

test 'link glossary' do
  visit root_path
  assert has_link?("Glossary")
  click_link "Glossary"
  assert_current_path glossary_path
end

test 'link contributors' do
  visit root_path
  assert has_link?("Contributors")
  click_link "Contributors"
  assert_current_path groups_path
end

test 'link about us' do
  visit root_path
  assert has_link?("About Us")
  click_link "About Us"
  assert_current_path about_us_path
end

test 'link sign in' do
  visit root_path
  assert has_link?("Sign in")
  click_link "Sign in"
  assert_current_path new_user_session_path
end


#page content
test 'do a dbsearch' do
    visit root_path

    fill_in 'search_param', with: 'than'

    click_button 'Search'

    assert page.has_content?(@one.display_name)
    assert page.has_content?(@two.display_name)
 end

test 'link to advanced search' do
     visit root_path

     assert has_link?("Advanced Search")
     click_link "Use Advanced Search"
     assert_current_path advanced_search_interactions_path
 end


 test 'link to chemeditor' do
     visit root_path

     assert page.has_content?("Search Molecules")
     assert has_link?("Chemeditor")
     click_link "Chemeditor"
     assert_current_path chemeditor_molecules_path
  end

  test 'link to about us from box' do
      visit root_path

      assert has_link?("about the SupraBank team")
      click_link "about the SupraBank team"
      assert_current_path about_us_path
   end

   test 'link to contributors from box' do
     visit root_path

     assert page.has_content?("Contributing groups")
     assert has_link?("here")
     click_link "here"
     assert_current_path groups_path
   end

 test 'content complete' do
     visit root_path

     assert page.has_content?("repository")
     assert has_link?("contact@suprabank.org")
     assert has_link?(href:"mailto:contact@suprabank.org")

     assert page.has_content?("Useful links")
     assert has_link?("supramolecular.org")
     assert has_link?(href:"http://supramolecular.org/")
     assert has_link?("Data Analysis")
     assert has_link?(href:"http://wernernau.user.jacobs-university.de/?page_id=420")
     assert has_link?("ASDSE fitting tools")
     assert has_link?(href:"https://github.com/ASDSE")
     assert has_link?("our group")
     assert has_link?(href:"https://www.biedermann-labs.com/")
     assert has_link?("kineticsimfit")
     assert has_link?(href:"https://github.com/ASDSE/kineticsimfit")
     assert has_link?("thermosimfit")
     assert has_link?(href:"https://github.com/ASDSE/thermosimfit")

     assert page.has_content?("News")
     assert has_link?(href:"https://twitter.com/supra_bank?ref_src=twsrc%5Etfw")
  end

#footer
  test 'link on footer logos' do
    visit root_path
    assert has_link?(href:"https://www.dfg.de/")
    assert has_link?(href:"https://www.kit.edu/")

  end

  test 'link homepage' do
    visit root_path
    assert has_link?("developed at the Institute of Nanotechnology")
    assert has_link?(href: "https://www.int.kit.edu")
  end

  test 'link legal' do
    visit root_path
    assert has_link?("Legal")
    click_link "Legal"
    assert_current_path legal_path
  end

  test 'welcome page do a valid dbsearch' do
      visit root_path

      fill_in 'search_param', with: 'than'
      click_button 'Search'

      assert page.has_content?("Info", count: 1)
      assert page.has_content?("Molecule", count: 2)
      assert page.has_content?("Partner", count: 2)
      assert page.has_content?("K", count: 2)
      assert page.has_content?("log K", count: 1)
      assert page.has_content?("Conditions", count: 1)
      assert page.has_content?("Supplement", count: 1)
      assert page.has_content?(@one.display_name)
      assert page.has_content?(@two.display_name)

  end

  test 'welcome page do an empty dbsearch' do
      visit root_path

      fill_in 'search_param', with: ''
      click_button 'Search'
      assert page.has_content?("You need to put some content")
   end

   test 'welcome page do an invalid dbsearch' do
       visit root_path

       fill_in 'search_param', with: 'xyz'
       click_button 'Search'
       assert page.has_content?("No Interaction was found, please use wildcards like xy%")
    end


end
