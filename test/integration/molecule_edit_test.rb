require 'test_helper'

class MoleculeEditTest < Capybara::Rails::TestCase
  include Warden::Test::Helpers
  def setup
    @molone = molecules :molecule_one
    @moltwo = molecules :molecule_two
    @user = users :user_one
    login_as(@user)
  end

  test 'normal user molecule index' do
    visit listing_molecules_path
    assert page.has_content?(@molone.display_name)
    assert page.has_content?(@moltwo.display_name)
  end

  test 'normal user complete molecule search page' do

    visit molecules_path
    assert page.has_content?("Search for Molecules")
    assert page.has_field?('Enter name of molecule; % serves as wildcard', type: 'text')
    assert page.has_selector?('#search_tag_tokens')

    click_button 'Search'
    assert page.has_content?("You need to put some content")

    visit molecules_path
    assert page.has_content?("Not found? Click me!")
    click_link "Not found? Click me!"

    assert page.has_content?("SupraBank is using external services to search and load molecules. Please tell us first what type of molecule you are interested in.")
    assert page.has_content?("Compound/small molecule") # - or why working?
    #assert page.has_css?('pubchem_help_link') - why not working?
    #assert page.has_content?("Protein") - why not working?
    #assert page.has_css?('pdb_help_link') - why not working?
  end

  test 'normal user search a molecule' do
    visit molecules_path

    fill_in 'search_param', with: 'ethanol'
    click_button 'Search'

    assert page.has_content?(@molone.display_name)
  end

  test 'normal user show all molecules' do
    visit molecules_path

    click_link 'Show all SupraBank molecules'
    assert_current_path listing_molecules_path
    assert page.has_content?(@molone.display_name)
    assert page.has_content?(@moltwo.display_name)
  end


  test 'normal user complete create molecule page' do
    visit new_molecule_path

    assert page.has_content?('Create a custom Molecule or Partner')
    assert page.has_content?('Common Name')
    assert page.has_selector?('#molecule_display_name')
    assert page.has_content?('Please provide a decent (common) name for the molecule to be displayed.')
    assert page.has_content?('Preferred abbreviation')
    assert page.has_selector?('#molecule_preferred_abbreviation')
    assert page.has_content?('A common abbreviation enables a facile representation of comlpicated names (e.g. CB, CD, CX or Trp-Gly-Trp)')
    assert page.has_content?('ISO SMILES')
    assert page.has_selector?('#molecule_iso_smiles')
    assert page.has_content?('Please provide the SMILES of the molecule, SupraBank is trying to do the rest for you, but you will be able to change anything.')

    assert page.has_content?('Molecules on SupraBank based on your SMILES. Please check before creation of a new entry.')
    assert page.has_content?('SBID/Link')
    assert page.has_content?('Name')
    assert page.has_content?('SMILES')
    assert page.has_content?('MW')

    assert page.has_button?("Create Molecule")
    assert page.has_link?("Cancel")

  end

  test 'normal user cancel create molecule' do
    visit new_molecule_path

    click_link 'Cancel'
    assert_current_path molecules_path
  end

  test 'normal user create unvalid molecule' do
    visit new_molecule_path
    click_button 'Create Molecule'
    assert page.has_content?("Display name can't be blank")
    assert page.has_content?("Iso smiles can't be blank")

    visit new_molecule_path
    find('#molecule_display_name').set('test molecule')
    click_button 'Create Molecule'
    assert_not page.has_content?("Display name can't be blank")
    assert page.has_content?("Iso smiles can't be blank")

    visit new_molecule_path
    find('#molecule_display_name').set('')
    find('#molecule_iso_smiles').set('CCO')
    click_button 'Create Molecule'
    assert page.has_content?("Display name can't be blank")
    assert_not page.has_content?("Iso smiles can't be blank")

  end

  test 'normal user create valid molecules' do
    visit new_molecule_path

    find('#molecule_display_name').set('test molecule')
    find('#molecule_iso_smiles').set('CCO')

    click_button 'Create Molecule'

    assert_current_path edit_molecule_path(Molecule.last)

    assert page.has_content?('SupraBank created successfully a molecule. Please thoroughly check everything and update accordingly.')
    assert page.has_content?('Edit Molecule')

    assert page.has_content?('Common Name *')
    assert page.has_field?('molecule_display_name', with: "test molecule")
    assert page.has_content?('Preferred Abbreviation *')
    assert page.has_content?('Molecular Weight')
    assert page.has_field?('molecule_molecular_weight', with: "46.06844")
    assert page.has_content?('Formula')
    assert page.has_field?('molecule_sum_formular', with: "C2H6O")
    assert page.has_content?('Tags')
    assert page.has_css?('#add_tag_tokens')
    assert page.has_css?('#instant_image')
    assert page.has_content?('Upload own image')
    assert page.has_content?('Upload ChemDraw File')

    assert page.has_content?('IsoSmiles')
    assert page.has_field?('molecule_iso_smiles', with: "CCO")
    assert page.has_content?('CanoSmiles')
    assert page.has_field?('molecule_cano_smiles', with: "CCO")
    assert page.has_content?('InChiKey')
    assert page.has_field?('molecule_inchikey', with: "LFQSCWFLJHTTHZ-UHFFFAOYSA-N")
    assert page.has_content?('InChi')
    assert page.has_field?('molecule_inchistring', with: "InChI=1S/C2H6O/c1-2-3/h3H,2H2,1H3")
    assert page.has_content?('IUPAC Name')

    assert page.has_content?('Number of H-Bond Donors')
    assert page.has_field?('molecule_h_bond_donor_count', with: "0.0")
    assert page.has_content?('Number of H-Bond Acceptors')
    assert page.has_field?('molecule_h_bond_acceptor_count', with: "0.0")
    assert page.has_content?('Number Stereogenic Bonds (E/Z)')
    assert page.has_content?('Number Stereogenic Atoms (R/S)')
    assert page.has_content?('Charge')
    assert page.has_field?('molecule_charge', with: "0.0")
    assert page.has_content?('3D Volume/Å3')
    assert page.has_content?('Complexity')
    assert page.has_content?('Number of Conformers')


    assert page.has_content?('CAS')
    assert page.has_content?('Fingerprint 2d')
    assert page.has_content?('Mdl string')

    assert page.has_button?("Update Molecule")
    assert page.has_link?("Cancel")

    find('#molecule_iupac_name').set('Testing fun')

    click_button("Update Molecule")
    assert_current_path molecule_path(Molecule.last)
    assert page.has_content?('Molecule was successfully updated.')
    assert page.has_content?('test molecule | SBID = ')
    assert page.has_content?('Testing fun')
    assert page.has_link?("Edit")

    click_link("Edit")
    assert_current_path edit_molecule_path(Molecule.last)
    assert_not page.has_content?('SupraBank created successfully a molecule. Please thoroughly check everything and update accordingly.')
    assert page.has_content?('Edit Molecule')

    click_link("Cancel")
    assert_current_path molecules_path

    visit new_molecule_path

    find('#molecule_display_name').set('test molecule')
    find('#molecule_iso_smiles').set('CCO')

    click_button 'Create Molecule'
    assert page.has_content?('Display name has already been taken')
  end

  test 'normal user edit pubchem molecule' do
    visit molecule_path(@molone)
    assert page.has_link?('Edit', :exact => true)
    assert_not page.has_link?('Delete', :exact => true)

    click_link("Edit")

    assert_current_path edit_molecule_path(@molone)

    assert page.has_content?('Edit Molecule')

    assert page.has_content?('Display name')
    assert page.has_field?('molecule_display_name', with: "ethanol")
    assert page.has_content?('Preferred abbreviation')
    assert page.has_field?('molecule_preferred_abbreviation', with: "ethanol")
    assert_not page.has_content?('Molecular Weight')
    assert_not page.has_content?('Formula')
    assert page.has_content?('CAS')
    assert page.has_field?('molecule_cas', with: "64-17-5")
    assert page.has_content?('Tags')
    assert page.has_css?('#tag_tokens')
    assert page.has_css?('#instant_image')
    assert page.has_content?('Upload new structure')
    assert page.has_content?('Upload ChemDraw File')

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

    assert page.has_content?('Synonyms')
    assert page.has_content?('ethyl alcohol')

    assert page.has_button?("Update Molecule")
    assert page.has_link?("Cancel")

    find('#molecule_cas').set('64-17-51')

    click_button("Update Molecule")
    assert_current_path molecule_path(@molone)
    assert page.has_content?('Molecule was successfully updated.')
    assert page.has_content?('ethanol | SBID = ')
    assert page.has_content?('64-17-51')
  end


end
