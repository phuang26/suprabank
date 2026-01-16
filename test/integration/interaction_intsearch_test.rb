require 'test_helper'

class InteractionIntsearchTest < Capybara::Rails::TestCase
  def setup
    @one = molecules :molecule_one
    @two = molecules :molecule_two
  end

  test 'do a valid dbsearch' do
      visit intsearch_interactions_path

      assert page.has_content?("Search Interactions")
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

  test 'do an empty dbsearch' do
      visit intsearch_interactions_path

      fill_in 'search_param', with: ''

      click_button 'Search'

      assert page.has_content?("You need to put some content")
   end

   test 'do an invalid dbsearch' do
       visit intsearch_interactions_path

       fill_in 'search_param', with: 'xyz'

       click_button 'Search'

       assert page.has_content?("No Interaction was found, please use wildcards like xy%")
    end

    test 'advance search link there' do
        visit intsearch_interactions_path

        assert page.has_content?("filter rich Advanced Search")
        click_link("filter rich Advanced Search")
        assert_current_path advanced_search_interactions_path
     end

end
