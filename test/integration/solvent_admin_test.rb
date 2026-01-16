require 'test_helper'

class SolventAdminTest < Capybara::Rails::TestCase
  include Warden::Test::Helpers
  def setup
    @one = solvents :solvent_one
    @two = solvents :solvent_two
    @three = solvents :solvent_three
    @four = solvents :solvent_four
    @user = users :admin
    login_as(@user)
  end


  test 'admin complete solvent search page' do

    visit solvents_path
    assert page.has_content?("Search for Solvents")
    assert page.has_field?('Enter name of solvent; % serves as wildcard', type: 'text')

    click_button 'Search'
    assert page.has_content?("You need to put some content")

    visit solvents_path
    click_link "Not found? Click me!"

    assert page.has_content?("PubChem powered search")
    #assert page.has_field?('by Solvent Name or CAS', type: 'text')
    #assert page.has_button?('Search in PubChem')
    #assert page.has_button?('Use CID instead')

  end

  test 'admin search a solvent' do
    visit solvents_path
    fill_in 'search_param', with: 'ethanol'
    click_button 'Search'
    assert_not page.has_content?(@one.display_name)
    assert page.has_content?(@two.display_name)
    assert page.has_content?(@three.display_name)
    assert_not page.has_content?(@four.display_name)

    visit solvents_path
    fill_in 'search_param', with: 'a'
    click_button 'Search'
    assert page.has_content?(@one.display_name)
    assert page.has_content?(@two.display_name)
    assert page.has_content?(@three.display_name)
    assert page.has_content?(@four.display_name)
  end

  test 'admin edit solvent' do
    visit solvent_path(@three)
    assert page.has_link?('Edit', :exact => true)
    assert_not page.has_link?('Delete', :exact => true)

    click_link("Edit")

    assert_current_path edit_solvent_path(@three)

    assert page.has_content?('Edit Solvent')

    assert page.has_content?('Display name')
    assert page.has_field?('solvent_display_name', with: "ethanol")
    assert page.has_content?('Preferred abbreviation')
    assert page.has_field?('solvent_preferred_abbreviation', with: "ethanol")
    assert_not page.has_content?('Molecular Weight')
    assert_not page.has_content?('Formula')
    assert page.has_content?('CAS')
    assert page.has_field?('solvent_cas')
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


    assert page.has_button?("Update Solvent")
    assert page.has_link?("Cancel")

    assert page.has_content?('Synonyms')

    find('#solvent_cas').set('64-17-5')

    click_button("Update Solvent")
    assert_current_path solvent_path(@three)
    assert page.has_content?('Solvent was successfully updated.')
    assert page.has_content?('Preview of ethanol | SBID =')
    assert page.has_content?('64-17-5')

  end

  test 'admin edit wrongly solvent' do
    visit solvent_path(@three)
    click_link("Edit")

    assert_current_path edit_solvent_path(@three)
    find('#solvent_display_name').set('')

    click_button("Update Solvent")
    assert page.has_content?("Display name can't be blank")
  end

end
