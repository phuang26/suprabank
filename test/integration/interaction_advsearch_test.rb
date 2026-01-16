require 'test_helper'

class InteractionAdvSearchTest < Capybara::Rails::TestCase
  def setup
    @one = molecules :molecule_one
    @two = molecules :molecule_two
  end

  test 'search fields exist' do
      visit advanced_search_interactions_path

      assert page.has_content?("Advanced Search")
      assert page.has_content?("Molecule/Guest")
      assert page.has_field?('name of e.g. guest, ligand', type: 'text')
      assert page.has_content?("exclusive", count: 2)
      assert page.has_selector?('#mol_tag_tokens')
      assert page.has_content?("OR")
      assert page.has_content?("Partner/Host")
      assert page.has_field?('name of e.g. host, protein', type: 'text')
      assert page.has_selector?('#host_tag_tokens')
      assert page.has_content?("Supplement")
      assert page.has_field?('name of e.g. cofactor or indicator', type: 'text')

      assert has_button?('Clear All')
      assert has_button?('More Options for Search')
      assert has_button?('Search')

      assert has_button?("Specify Method")
        assert page.has_content?("Assay")
        assert page.has_field?('DBA, CBA, ABA', type: 'text')
        assert page.has_content?("Technique")
        assert page.has_field?('NMR, FL, ITC ...', type: 'text')

      assert has_button?("Specify Binding")
        assert page.has_content?("K")
        assert page.has_field?('from', type: 'text', count: 3)
        assert page.has_content?("log K")
        assert page.has_field?('to', type: 'text', count: 4)

      assert has_button?("Specify Conditions")
        assert page.has_content?("Solvent")
        assert page.has_field?('solvent', type: 'text')
        assert page.has_content?("Buffer")
        assert page.has_field?('buffer', type: 'text')
        assert page.has_content?("pH")
        assert page.has_content?("Temperature")

      assert has_button?("Specify Citation")
        assert page.has_content?("DOI")
        assert page.has_field?('DOI', type: 'text')
        assert page.has_content?("Author")
        assert page.has_field?('Author', type: 'text')
        assert page.has_content?("Year")
        assert page.has_field?('Year', type: 'text')
   end

  test 'do an empty advanced search' do
      visit advanced_search_interactions_path

      click_button 'Search'

      assert page.has_content?("You need to put some content")
   end

   test 'do an invalid advanced search' do
       visit advanced_search_interactions_path
       fill_in 'molecule_param', with: 'xyz'
       click_button 'Search'
       assert page.has_content?("No Interaction was found.")


    end


    test 'do a valid advanced search' do
        visit advanced_search_interactions_path

        fill_in 'molecule_param', with: 'ethanol'

        click_button 'Search'

        assert page.has_content?("Info", count: 1)
        assert page.has_content?("Molecule", count: 2)
        assert page.has_content?("Partner", count: 2)
        assert page.has_content?("K", count: 2)
        assert page.has_content?("log K", count: 1)
        assert page.has_content?("Conditions", count: 1)
        assert page.has_content?("Supplement", count: 1)
        assert page.has_content?(@one.display_name, count: 1)
        assert page.has_content?(@two.display_name, count: 1)
     end

     test 'search a tag' do
       visit advanced_search_interactions_path

       fill_in 'mol_tag_tokens', with: 'alcohol'
       click_button 'Search'

       assert page.has_content?("Info", count: 1)
       assert page.has_content?("Molecule", count: 2)
       assert page.has_content?("Partner", count: 2)
       assert page.has_content?("K", count: 2)
       assert page.has_content?("log K", count: 1)
       assert page.has_content?("Conditions", count: 1)
       assert page.has_content?("Supplement", count: 1)
       assert page.has_content?(@one.display_name, count: 1)
       assert page.has_content?(@two.display_name, count: 1)

     end
end
