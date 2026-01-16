require 'test_helper'

class AdditiveAdminTest < Capybara::Rails::TestCase
  include Warden::Test::Helpers
  def setup
    @one = additives :additive_one
    @two = additives :additive_two
    @user = users :admin
    login_as(@user)
  end


  test 'admin complete additive search page' do

    visit additives_path
    assert page.has_content?("Search for Additives")
    assert page.has_field?('Enter name of additive; % serves as wildcard', type: 'text')

    click_button 'Search'
    assert page.has_content?("You need to put some content")

    visit additives_path
    click_link "Not found? Click me!"

    assert page.has_content?("PubChem powered search")
    #assert page.has_field?('by additive Name or CAS', type: 'text')
    #assert page.has_button?('Search in PubChem')
    #assert page.has_button?('Use CID instead')

  end

  test 'admin search a additive' do
    visit additives_path
    fill_in 'search_param', with: 'sodium chloride'
    click_button 'Search'
    assert page.has_content?(@one.display_name)
    assert page.has_content?(@two.display_name)
  end

  test 'admin edit additive' do
    visit additive_path(@two)
    assert page.has_link?('Edit', :exact => true)
    assert_not page.has_link?('Delete', :exact => true)

    click_link("Edit")

    assert_current_path edit_additive_path(@two)

    assert page.has_content?('Edit Additive')

    assert page.has_content?('Display name')
    assert page.has_field?('additive_display_name', with: "sodium iodide")
    assert page.has_content?('Preferred abbreviation')
    assert page.has_field?('additive_preferred_abbreviation', with: "sodium iodide")
    assert_not page.has_content?('Molecular Weight')
    assert_not page.has_content?('Formula')
    assert page.has_content?('CAS')
    assert page.has_field?('additive_cas')
    #assert_not page.has_content?('Tags')
    assert_not page.has_content?('Upload new structure')
    assert_not page.has_content?('Upload ChemDraw File')

    assert_not page.has_content?('IsoSmiles')
    assert_not page.has_content?('CanoSmiles')
    assert_not page.has_content?('InChiKey')
    assert_not page.has_content?('InChi')
    assert_not page.has_content?('IUPAC Name')

    assert_not page.has_content?('Number of H-Bond Donors')
    assert_not page.has_content?('Number of H-Bond Acceptors')
    assert_not page.has_content?('Number Stereogenic Bonds (E/Z)')
    assert_not page.has_content?('Number Stereogenic Atoms (R/S)')
    assert_not page.has_content?('Charge')
    assert_not page.has_content?('3D Volume/Å3')
    assert_not page.has_content?('Complexity')
    assert_not page.has_content?('Number of Conformers')

    assert_not page.has_content?('Fingerprint 2d')
    assert_not page.has_content?('Mdl string')


    assert page.has_button?("Update Additive")
    assert page.has_link?("Cancel")

    assert page.has_content?('Synonyms')

    find('#additive_cas').set('7681-82-5')

    click_button("Update Additive")
    assert_current_path additive_path(@two)
    assert page.has_content?('Additive was successfully updated.')
    assert page.has_content?('Preview of sodium iodide | SBID =')
    assert page.has_content?('7681-82-5')

  end

  test 'admin edit wrongly additive' do
    visit additive_path(@two)
    click_link("Edit")

    assert_current_path edit_additive_path(@two)
    find('#additive_display_name').set('')

    click_button("Update Additive")
    assert page.has_content?("Display name can't be blank")
  end

end
