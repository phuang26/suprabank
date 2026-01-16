require 'test_helper'

class InteractionNormaluserAdvSearchTest < Capybara::Rails::TestCase
  include Warden::Test::Helpers
  def setup
    @one = molecules :molecule_one
    @two = molecules :molecule_two
    @user = users :user_one
    login_as(@user)
  end

  test 'normal user advsearch fields exist' do
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
        fill_in 'molecule_param', with: 'xyz'
        click_button 'Clear All'
        assert_not page.has_content?('xyz')

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

  test 'normal user advsearch do an empty advanced search' do
      visit advanced_search_interactions_path

      click_button 'Search'

      assert page.has_content?("You need to put some content")
   end

   test 'normal user advsearch do an invalid advanced search' do
       visit advanced_search_interactions_path
       fill_in 'molecule_param', with: 'xyz'
       click_button 'Search'
       assert page.has_content?("No Interaction was found.")

    end


    test 'normal user advsearch do a valid advanced search' do
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
        assert page.has_content?(@one.display_name)
        assert page.has_content?(@two.display_name)

        visit advanced_search_interactions_path
        fill_in 'molecule_param', with: 'butanol'
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

        visit advanced_search_interactions_path
        fill_in 'molecule_param', with: 'butanol'
        find('#molecule_exclusive_param').set("yes")
        click_button 'Search'
        assert page.has_content?("No Interaction was found.")
     end

     test 'normal user advsearch search a tag' do
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
       assert page.has_content?(@one.display_name)
       assert page.has_content?(@two.display_name)

     end

     test 'normal user advsearch search by host' do
       visit advanced_search_interactions_path
       fill_in 'host_param', with: 'butanol'
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

       visit advanced_search_interactions_path
       fill_in 'host_param', with: 'ethanol'
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

       visit advanced_search_interactions_path
       fill_in 'host_param', with: 'ethanol'
       find('#host_exclusive_param').set("yes")
       click_button 'Search'
       assert page.has_content?("No Interaction was found.")

     end

     test 'normal user advsearch search with or option' do
       visit advanced_search_interactions_path
       fill_in 'molecule_param', with: 'ethanol'
       fill_in 'host_param', with: 'Cobalt'
       click_button 'Search'
       assert page.has_content?("No Interaction was found.")

       visit advanced_search_interactions_path
       fill_in 'molecule_param', with: 'ethanol'
       fill_in 'host_param', with: 'Cobalt'
       find('#host_or_param').set("yes")
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

       visit advanced_search_interactions_path
       fill_in 'molecule_param', with: 'butanol'
       fill_in 'host_param', with: 'ethanol'
       find('#host_or_param').set("yes")
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
       assert_not page.has_content?('Arsenic')


       visit advanced_search_interactions_path
       fill_in 'molecule_param', with: 'butanol'
       fill_in 'host_param', with: 'ethanol'
       find('#host_or_param').set("yes")
       find('#molecule_exclusive_param').set("yes")
       find('#host_exclusive_param').set("yes")
       click_button 'Search'
       assert page.has_content?("No Interaction was found.")
     end

     test 'normal user advsearch search Supplement' do
       visit advanced_search_interactions_path
       fill_in 'supplement_param', with: 'ethanol'
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

       visit advanced_search_interactions_path
       fill_in 'supplement_param', with: 'cethanol'
       click_button 'Search'
       assert page.has_content?("No Interaction was found.")
     end

     test 'normal user advsearch search assays' do
       visit advanced_search_interactions_path
       fill_in 'assay_type_param', with: 'Direct Binding Assay'
       click_button 'Search'
       assert page.has_content?("Info", count: 1)
       assert page.has_content?("Molecule", count: 2)
       assert page.has_content?(@one.display_name)
       assert page.has_content?(@two.display_name)
       assert page.has_content?('water')
       assert page.has_content?('complex')

       visit advanced_search_interactions_path
       fill_in 'assay_type_param', with: 'Associative Binding Assay'
       click_button 'Search'
       assert page.has_content?("Info", count: 1)
       assert page.has_content?("Molecule", count: 2)
       assert page.has_content?(@one.display_name)
       assert page.has_content?(@two.display_name)
       assert_not page.has_content?('water')
       assert_not page.has_content?('complex')
       assert page.has_content?('buffer')

       visit advanced_search_interactions_path
       fill_in 'assay_type_param', with: 'Competitive Binding Assay'
       click_button 'Search'
       assert page.has_content?("Info", count: 1)
       assert page.has_content?("Molecule", count: 2)
       assert page.has_content?(@one.display_name)
       assert page.has_content?(@two.display_name)
       assert_not page.has_content?('water')
       assert page.has_content?('complex')
       assert_not page.has_content?('buffer')

       visit advanced_search_interactions_path
       fill_in 'assay_type_param', with: 'xyz'
       click_button 'Search'
       assert page.has_content?("No Interaction was found.")
    end

     test 'normal user advsearch search techniques' do
       visit advanced_search_interactions_path
       fill_in 'technique_param', with: 'Fluorescence'
       click_button 'Search'
       assert page.has_content?("Info", count: 1)
       assert page.has_content?("Molecule", count: 2)
       assert page.has_content?(@one.display_name)
       assert page.has_content?(@two.display_name)

       visit advanced_search_interactions_path
       fill_in 'technique_param', with: 'Absorbance'
       click_button 'Search'
       assert page.has_content?("Info", count: 1)
       assert page.has_content?("Molecule", count: 2)
       assert page.has_content?(@one.display_name)
       assert page.has_content?(@two.display_name)

       visit advanced_search_interactions_path
       fill_in 'technique_param', with: 'Isothermal Titration Calorimetry'
       click_button 'Search'
       assert page.has_content?("Info", count: 1)
       assert page.has_content?("Molecule", count: 2)
       assert page.has_content?(@one.display_name)
       assert page.has_content?(@two.display_name)

       visit advanced_search_interactions_path
       fill_in 'technique_param', with: 'Nuclear Magnetic Resonance'
       click_button 'Search'
       assert page.has_content?("Info", count: 1)
       assert page.has_content?("Molecule", count: 2)
       assert page.has_content?(@one.display_name)
       assert page.has_content?(@two.display_name)

       visit advanced_search_interactions_path
       fill_in 'technique_param', with: 'Surface Enhanced Raman Scattering'
       click_button 'Search'
       assert page.has_content?("Info", count: 1)
       assert page.has_content?("Molecule", count: 2)
       assert page.has_content?(@one.display_name)
       assert page.has_content?(@two.display_name)

       visit advanced_search_interactions_path
       fill_in 'technique_param', with: 'Circular Dichroism'
       click_button 'Search'
       assert page.has_content?("Info", count: 1)
       assert page.has_content?("Molecule", count: 2)
       assert page.has_content?(@one.display_name)
       assert page.has_content?(@two.display_name)

       visit advanced_search_interactions_path
       fill_in 'technique_param', with: 'Potentiometry'
       click_button 'Search'
       assert page.has_content?("Info", count: 1)
       assert page.has_content?("Molecule", count: 2)
       assert page.has_content?(@one.display_name)
       assert page.has_content?(@two.display_name)

       visit advanced_search_interactions_path
       fill_in 'technique_param', with: 'Extraction'
       click_button 'Search'
       assert page.has_content?("Info", count: 1)
       assert page.has_content?("Molecule", count: 2)
       assert page.has_content?(@one.display_name)
       assert page.has_content?(@two.display_name)
       visit advanced_search_interactions_path

       fill_in 'technique_param', with: 'Electron Paramagnetic Resonance'
       click_button 'Search'
       assert page.has_content?("Info", count: 1)
       assert page.has_content?("Molecule", count: 2)
       assert page.has_content?(@one.display_name)
       assert page.has_content?(@two.display_name)

       visit advanced_search_interactions_path
       fill_in 'technique_param', with: 'xyz'
       click_button 'Search'
       assert page.has_content?("No Interaction was found.")
     end

     test 'normal user advsearch search binding constant' do
       visit advanced_search_interactions_path
       fill_in 'molecule_param', with: 'ethanol'
       fill_in 'ka_upper', with: '1000'
       click_button 'Search'
       assert page.has_content?("Info", count: 1)
       assert page.has_content?("Molecule", count: 2)
       assert page.has_content?(@one.display_name)
       assert page.has_content?(@two.display_name)
       assert page.has_content?("complex")
       assert page.has_content?("water")

       visit advanced_search_interactions_path
       fill_in 'molecule_param', with: 'ethanol'
       fill_in 'ka_upper', with: '1000'
       fill_in 'ka', with: '900'
       click_button 'Search'
       assert page.has_content?("Info", count: 1)
       assert page.has_content?("Molecule", count: 2)
       assert page.has_content?(@one.display_name)
       assert page.has_content?(@two.display_name)
       assert page.has_content?("complex")
       assert_not page.has_content?("water")

       visit advanced_search_interactions_path
       fill_in 'molecule_param', with: 'ethanol'
       fill_in 'ka', with: '2000'
       click_button 'Search'
       assert page.has_content?("Info", count: 1)
       assert page.has_content?("Molecule", count: 2)
       assert page.has_content?(@one.display_name)
       assert page.has_content?(@two.display_name)
       assert page.has_content?("complex")
       assert page.has_content?("buffer")
       assert_not page.has_content?("water")

       visit advanced_search_interactions_path
       fill_in 'molecule_param', with: 'ethanol'
       fill_in 'ka_upper', with: '0'
       click_button 'Search'
       assert page.has_content?("No Interaction was found.")
     end

   test 'normal user advsearch search unvalid binding constant' do
     visit advanced_search_interactions_path
     fill_in 'molecule_param', with: 'ethanol'
     fill_in 'ka', with: '10e20'
     click_button 'Search'
     assert page.has_content?("No Interaction was found.")
   end

   #no tests for filling in logK values  as the calculation of the corresponding K values is javascript based and, thus, nothing happens here

   test 'normal user advsearch search pH' do
     visit advanced_search_interactions_path
     fill_in 'pH_to_param', with: '8'
     click_button 'Search'
     assert page.has_content?("Info", count: 1)
     assert page.has_content?("Molecule", count: 2)
     assert page.has_content?(@one.display_name)
     assert page.has_content?(@two.display_name)
     assert page.has_content?("complex")
     assert page.has_content?("water")

     visit advanced_search_interactions_path
     fill_in 'pH_to_param', with: 'xyz'
     click_button 'Search'
     assert page.has_content?("No Interaction was found.")

     visit advanced_search_interactions_path
     fill_in 'pH_to_param', with: '8'
     fill_in 'pH_param', with: '7.3'
     click_button 'Search'
     assert page.has_content?("Info", count: 1)
     assert page.has_content?("Molecule", count: 2)
     assert page.has_content?(@one.display_name)
     assert page.has_content?(@two.display_name)
     assert_not page.has_content?("complex")
     assert page.has_content?("water")

     visit advanced_search_interactions_path
     fill_in 'pH_param', with: '5'
     click_button 'Search'
     assert page.has_content?("Info", count: 1)
     assert page.has_content?("Molecule", count: 2)
     assert page.has_content?(@one.display_name)
     assert page.has_content?(@two.display_name)
     assert page.has_content?("complex")
     assert page.has_content?("water")

     visit advanced_search_interactions_path
     fill_in 'pH_param', with: '9'
     click_button 'Search'
     assert page.has_content?("No Interaction was found.")
  end

  test 'normal user advsearch search temperature' do
    visit advanced_search_interactions_path
    fill_in 'temperature_to_param', with: '26'
    click_button 'Search'
    assert page.has_content?("Info", count: 1)
    assert page.has_content?("Molecule", count: 2)
    assert page.has_content?(@one.display_name)
    assert page.has_content?(@two.display_name)
    assert page.has_content?("complex")
    assert page.has_content?("water")

    visit advanced_search_interactions_path
    fill_in 'temperature_to_param', with: '26'
    fill_in 'temperature_param', with: '23'
    click_button 'Search'
    assert page.has_content?("Info", count: 1)
    assert page.has_content?("Molecule", count: 2)
    assert page.has_content?(@one.display_name)
    assert page.has_content?(@two.display_name)
    assert page.has_content?("complex")
    assert page.has_content?("water")

    visit advanced_search_interactions_path
    fill_in 'temperature_param', with: '23'
    click_button 'Search'
    assert page.has_content?("Info", count: 1)
    assert page.has_content?("Molecule", count: 2)
    assert page.has_content?(@one.display_name)
    assert page.has_content?(@two.display_name)
    assert page.has_content?("complex")
    assert page.has_content?("water")

    visit advanced_search_interactions_path
    fill_in 'temperature_to_param', with: '20'
    click_button 'Search'
    assert page.has_content?("No Interaction was found.")
  end

  test 'normal user advsearch search unvalid temperature' do
    visit advanced_search_interactions_path
    fill_in 'temperature_param', with: '30'
    click_button 'Search'
    assert page.has_content?("No Interaction was found.")
 end

 test 'normal user advsearch search doi' do
   visit advanced_search_interactions_path
   fill_in 'molecule_param', with: 'ethanol'
   fill_in 'doi_param', with: '10.1021/jacs.6b07655'
   click_button 'Search'
   assert page.has_content?("Info", count: 1)
   assert page.has_content?("Molecule", count: 2)
   assert page.has_content?(@one.display_name)
   assert page.has_content?(@two.display_name)
   assert page.has_content?("complex")
   assert page.has_content?("water")

   visit advanced_search_interactions_path
   fill_in 'molecule_param', with: 'ethanol'
   fill_in 'doi_param', with: '10.1039/D0CC03715J'
   click_button 'Search'
   assert page.has_content?("Info", count: 1)
   assert page.has_content?("Molecule", count: 2)
   assert page.has_content?(@one.display_name)
   assert page.has_content?(@two.display_name)
   assert_not page.has_content?("complex")
   assert_not page.has_content?("water")

   visit advanced_search_interactions_path
   fill_in 'molecule_param', with: 'ethanol'
   fill_in 'doi_param', with: 'xyz'
   click_button 'Search'
   assert page.has_content?("No Interaction was found.")
 end

 test 'normal user advsearch search author' do
   visit advanced_search_interactions_path
   fill_in 'author_param', with: 'Biedermann'
   click_button 'Search'
   assert page.has_content?("Info", count: 1)
   assert page.has_content?("Molecule", count: 2)
   assert page.has_content?(@one.display_name)
   assert page.has_content?(@two.display_name)
   assert_not page.has_content?("complex")
   assert page.has_content?("water")

   visit advanced_search_interactions_path
   fill_in 'author_param', with: 'xyz'
   click_button 'Search'
   assert page.has_content?("No Interaction was found.")
 end


 test 'normal user advsearch search year' do
   visit advanced_search_interactions_path
   fill_in 'year_param', with: '2016'
   click_button 'Search'
   assert page.has_content?("Info", count: 1)
   assert page.has_content?("Molecule", count: 2)
   assert page.has_content?(@one.display_name)
   assert page.has_content?(@two.display_name)
   assert_not page.has_content?("complex")
   assert page.has_content?("water")

   visit advanced_search_interactions_path
   fill_in 'year_param', with: 'xyz'
   click_button 'Search'
   assert page.has_content?("No Interaction was found.")
 end

 test 'normal user advsearch fill in everything' do
   visit advanced_search_interactions_path
   fill_in 'assay_type_param', with: 'Direct Binding Assay'
   fill_in 'technique_param', with: 'Fluorescence'
   fill_in 'molecule_param', with: 'ethanol'
   fill_in 'mol_tags_param', with: 'alcohol'
   fill_in 'host_param', with: 'butanol'
   fill_in 'ka_upper', with: '73'
   fill_in 'solvent_param', with: 'water'
   fill_in 'pH_param', with: '7.1'
   fill_in 'doi_param', with: '10.1021/jacs.6b07655'
   fill_in 'author_param', with: 'Biedermann'
   fill_in 'year_param', with: '2016'
   click_button 'Search'
   assert page.has_content?("Info", count: 1)
   assert page.has_content?("Molecule", count: 2)
   assert page.has_content?(@one.display_name)
   assert page.has_content?(@two.display_name)
   assert_not page.has_content?("complex")
   assert page.has_content?("water")

 end

end
