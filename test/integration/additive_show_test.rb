require 'test_helper'

class AdditiveShowTest < Capybara::Rails::TestCase

  def setup
    @one = additives :additive_one
    @two = additives :additive_two
  end

#----------Search additive -------------------------

  test 'complete additive search page' do
    visit additives_path

    assert page.has_content?("Search for Additives")
    assert page.has_field?('Enter name of additive; % serves as wildcard', type: 'text')
    assert_not page.has_link?("New")
    assert_not page.has_link?('Not found? Click me!')

    click_button 'Search'
    assert page.has_content?("You need to put some content")

  end

  test 'search a additive' do
    visit additives_path

    fill_in 'search_param', with: 'sodium'
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

  test 'search a unvalid additive' do
    visit additives_path

    fill_in 'search_param', with: 'xyz'
    click_button 'Search'
    assert page.has_content?("Nothing found in the database Additives")
    assert_not page.has_content?("Actions")

  end


#--------new additive---------------

  test 'try to create new additive' do
    visit "/additives/new"
    assert_current_path additives_path

    assert_not page.has_content?('You need to sign in or sign up before continuing.')
  end


#--------additive overview---------------

  test 'overview page of additive_one complete' do

    visit additive_path(@one)

    assert page.has_content?('Preview of sodium chloride | SBID =')

    assert page.has_content?('Structure')
    assert page.has_css?("#additive_image", count:1)

    assert page.has_content?('Molecular Properties')
    assert page.has_content?('TPSA/Å2:')
    assert page.has_content?(@one.tpsa)
    assert page.has_content?('Hydrophilicity (XLogP):')
    assert page.has_content?(@one.x_log_p)
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
    assert page.has_content?('Name:')
    assert page.has_content?(@one.display_name)
    assert page.has_content?('Preferred abbreviation:')
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

    assert page.has_link?('Back', :exact => true)
    assert_not page.has_link?('Edit', :exact => true)
    assert_not page.has_link?('Delete', :exact => true)
  end

end
