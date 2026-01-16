require 'test_helper'

class MoleculeShowTest < Capybara::Rails::TestCase

  def setup
    @one = molecules :molecule_one
    @two = molecules :molecule_two
  end

#----------Search by names or tags -------------------------

  test 'complete molecule search page' do
    visit molecules_path

    assert page.has_content?("Search for Molecules")
    assert page.has_field?('Enter name of molecule; % serves as wildcard', type: 'text')
    assert page.has_selector?('#search_tag_tokens')
    assert_not page.has_link?('Not found? Click me!')

    click_button 'Search'
    assert page.has_content?("You need to put some content")

  end

  test 'search a molecule' do
    visit molecules_path

    fill_in 'search_param', with: 'ethanol'
    click_button 'Search'

    assert page.has_content?("Info")
    assert page.has_content?("Name")
    assert page.has_content?("Structure")
    assert page.has_content?("M / g/mol")
    assert page.has_content?("Interactions")
    assert page.has_content?("Identifier")
    assert page.has_content?("Updated")
    assert page.has_content?(@one.display_name)
    assert_not page.has_content?(@two.display_name)
    assert page.has_content?("PubChem")
    assert page.has_content?("InChI")
    assert page.has_content?("Smiles")

  end

  test 'search a tag' do
    visit molecules_path

    fill_in 'search_tag_tokens', with: 'alcohol'
    click_button 'Search'

    assert page.has_content?("Info")
    assert page.has_content?("Name")
    assert page.has_content?("Structure")
    assert page.has_content?("M / g/mol")
    assert page.has_content?("Interactions")
    assert page.has_content?("Identifier")
    assert page.has_content?("Updated")
    assert page.has_content?(@one.display_name)
    assert_not page.has_content?(@two.display_name)
    assert page.has_content?("PubChem")
    assert page.has_content?("InChI")
    assert page.has_content?("Smiles")

  end

  test 'search a unvalid molecule' do
    visit molecules_path

    fill_in 'search_param', with: 'xyz'
    click_button 'Search'
    assert page.has_content?("Nothing found in the database Molecules")
    assert_not page.has_content?("Info")

  end

  test 'show all molecules' do
    visit molecules_path

    click_link 'Show all SupraBank molecules'
    assert_current_path listing_molecules_path

    assert page.has_content?("Info")
    assert page.has_content?("Name")
    assert page.has_content?("Structure")
    assert page.has_content?("M / g/mol")
    assert page.has_content?("Interactions")
    assert page.has_content?("Identifier")
    assert page.has_content?("Updated")
    assert page.has_content?(@one.display_name)
    assert page.has_content?(@two.display_name)
    assert page.has_content?("PubChem")
    assert page.has_content?("InChI")
    assert page.has_content?("Smiles")
  end

#-----------Search using Editor ---------------------

  test 'complete editor search page' do
    visit chemeditor_molecules_path

    assert page.has_content?("Chemical Editor")
    assert page.has_selector?('#my-editor')
    assert page.has_button?('Exact Search')
    assert page.has_button?('SMILES Search')
    assert page.has_button?('Get Molfile')

    click_button 'Exact Search'
    #assert page.has_content?('You need to put some content') - why not?

    visit chemeditor_molecules_path
    click_button 'SMILES Search'
    #assert page.has_content?('You need to put some content')
  end

#------------ New Molecule ---------------

  test 'try to create new molecule' do
    visit new_molecule_path

    assert page.has_content?('You need to sign in or sign up before continuing.')
    assert_current_path new_user_session_path
    fill_in "Email", with: "normaluser@mailinator.com"
    fill_in "Password", with: "123456"
    click_button("Log in")
    assert_current_path new_molecule_path
    assert page.has_content?('Preferred abbreviation')

  end

  test 'overview page of molecule_one complete' do

    visit molecule_path(@one)

    assert page.has_content?('ethanol | SBID = ')
    assert page.has_content?('| Compound | ')

    assert page.has_content?('Structure')
    assert page.has_css?(".structure-image", count:1)

    assert page.has_content?('Molecular Properties')
    assert page.has_content?('Interactions')
    assert page.has_content?('15')
    assert page.has_content?('PubChem TPSA/Å2:')
    assert page.has_content?(@one.tpsa)
    assert page.has_content?('Ertl TPSA/Å2:')
    assert page.has_content?(@one.ertl_tpsa)
    assert page.has_content?('Hydrophilicity (PubChem XLogP):')
    assert page.has_content?(@one.x_log_p)
    assert page.has_content?('Hydrophilicity (Cheng XLogP3):')
    assert page.has_content?(@one.cheng_xlogp3)
    assert page.has_content?('Charge:')
    assert page.has_content?(@one.charge)
    assert page.has_content?('Number of H-Bond Donors:')
    assert page.has_content?(@one.h_bond_donor_count)
    assert page.has_content?('Number of H-Bond Acceptors:')
    assert page.has_content?(@one.h_bond_acceptor_count)
    assert page.has_content?('Number of Stereogenic Bonds (E/Z):')
    assert page.has_content?(@one.bond_stereo_count)
    assert page.has_content?('Number of Stereogenic Atoms (R/S):')
    assert page.has_content?(@one.atom_stereo_count)
    assert page.has_content?('3D Volume/Å3:')
    assert page.has_content?(@one.volume_3d)
    assert page.has_content?('Sum Formula:')
    assert page.has_content?(@one.sum_formular)
    assert page.has_content?('M / g/mol:')
    assert page.has_content?(@one.molecular_weight)
    assert page.has_content?('Complexity:')
    assert page.has_content?(@one.complexity)
    assert page.has_content?('Number of Conformers:')
    assert page.has_content?(@one.conformer_count_3d)

    assert page.has_content?('Identifiers')
    assert page.has_content?('Tags:')
    assert page.has_content?(@one.tag_list)
    assert page.has_content?('Name:')
    assert page.has_content?(@one.display_name)
    assert page.has_content?('Preferred Abbreviation:')
    assert page.has_content?(@one.preferred_abbreviation)
    assert page.has_content?('IUPAC Name:')
    assert page.has_content?(@one.iupac_name)
    assert page.has_content?('CAS:')
    assert page.has_content?(@one.cas)
    assert page.has_content?('CID:')
    assert page.has_content?(@one.cid)
    assert page.has_content?('InChiKey:')
    assert page.has_content?(@one.inchikey)
    assert page.has_content?('InChi:')
    assert page.has_content?(@one.inchistring)
    assert page.has_content?('CanoSmiles:')
    assert page.has_content?(@one.cano_smiles)
    assert page.has_content?('IsoSmiles:')
    assert page.has_content?(@one.iso_smiles)


    assert_not page.has_link?('Edit', :exact => true)
    assert_not page.has_link?('Delete', :exact => true)
  end

end
