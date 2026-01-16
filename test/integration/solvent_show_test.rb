require 'test_helper'

class SolventShowTest < Capybara::Rails::TestCase

  def setup
    @one = solvents :solvent_one
    @two = solvents :solvent_two
    @four = solvents :solvent_four
  end

#----------Search solvent -------------------------

  test 'complete solvent search page' do
    visit solvents_path

    assert page.has_content?("Search for Solvents")
    assert page.has_field?('Enter name of solvent; % serves as wildcard', type: 'text')
    assert_not page.has_link?("New")
    assert_not page.has_link?('Not found? Click me!')

    click_button 'Search'
    assert page.has_content?("You need to put some content")

  end

  test 'search a solvent' do
    visit solvents_path

    fill_in 'search_param', with: 'water'
    click_button 'Search'

    assert page.has_content?("Actions")
    assert page.has_content?("Name")
    assert page.has_content?("Interactions")
    #assert page.has_content?("M / g/mol")
    assert page.has_content?("SBID")
    assert page.has_content?("CID")
    assert page.has_content?("Identifier")
    #assert page.has_content?("No data available in table") probably javascript
  end

  test 'search a unvalid solvent' do
    visit solvents_path

    fill_in 'search_param', with: 'xyz'
    click_button 'Search'
    assert page.has_content?("Nothing found in the database Solvents")
    assert_not page.has_content?("Actions")

  end


#--------new solvent---------------

  test 'try to create new solvent' do
    visit "/solvents/new"
    assert_current_path solvents_path
    assert_not page.has_content?('You need to sign in or sign up before continuing.')

  end


#--------solvent overview---------------

  test 'overview page of solvent_four complete' do

    visit solvent_path(@four)

    assert page.has_content?('Preview of butanol | SBID =')

    assert page.has_content?('Structure')
    assert page.has_css?("#solvent_image", count:1)

    assert page.has_content?('Molecular Properties')
    assert page.has_content?('TPSA/Å2:')
    assert page.has_content?(@four.tpsa)
    assert page.has_content?('Hydrophilicity (XLogP):')
    assert page.has_content?(@four.x_log_p)
    assert page.has_content?('Charge:')
    assert page.has_content?(@four.charge)
    assert page.has_content?('Number of H-Bond Donors:')
    assert page.has_content?(@four.h_bond_donor_count)
    assert page.has_content?('Number of H-Bond Acceptors:')
    assert page.has_content?(@four.h_bond_acceptor_count)
    assert page.has_content?('Number of Stereogenic Bonds (E/Z):')
    assert page.has_content?(@four.bond_stereo_count)
    assert page.has_content?('Number of Stereogenic Atoms (R/S):')
    assert page.has_content?(@four.atom_stereo_count)
    assert page.has_content?('3D Volume/Å3:')
    assert page.has_content?(@four.volume_3d)
    assert page.has_content?('Sum Formula:')
    assert page.has_content?(@four.sum_formular)
    assert page.has_content?('M / g/mol:')
    assert page.has_content?(@four.molecular_weight)
    assert page.has_content?('Complexity:')
    assert page.has_content?(@four.complexity)
    assert page.has_content?('Number of Conformers:')
    assert page.has_content?(@four.conformer_count_3d)

    assert page.has_content?('Identifiers')
    assert page.has_content?('Name:')
    assert page.has_content?(@four.display_name)
    assert page.has_content?('Preferred abbreviation:')
    assert page.has_content?(@four.preferred_abbreviation)
    assert page.has_content?('IUPAC Name:')
    assert page.has_content?(@four.iupac_name)
    assert page.has_content?('CAS:')
    assert page.has_content?(@four.cas)
    assert page.has_content?('CID:')
    assert page.has_content?(@four.cid)
    assert page.has_content?('InChiKey:')
    assert page.has_content?(@four.inchikey)
    assert page.has_content?('InChi:')
    assert page.has_content?(@four.inchistring)
    assert page.has_content?('CanoSmiles:')
    assert page.has_content?(@four.cano_smiles)
    assert page.has_content?('IsoSmiles:')
    assert page.has_content?(@four.iso_smiles)

    assert page.has_link?('Back', :exact => true)
    assert_not page.has_link?('Edit', :exact => true)
    assert_not page.has_link?('Delete', :exact => true)
  end

end
