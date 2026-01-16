require 'test_helper'

class InteractionFormNormalUserTest < Capybara::Rails::TestCase
  include Warden::Test::Helpers
  def setup
    @one = interactions :interaction_one
    @two = interactions :interaction_two
    @five = interactions :interaction_five
    @published = interactions :interaction_published
    @molone = molecules :molecule_one
    @moltwo = molecules :molecule_two
    @molthree = molecules :molecule_three
    @user = users :user_one
    login_as(@user)
  end

#------------new form-----------------
  test 'complete new interaction form' do
    visit new_interaction_path

    assert page.has_content?('New Interaction')
    assert page.has_content?('Assay')
    assert page.has_selector?('.assay-type', count: 3)
    assert page.has_content?('Technique')
    assert page.has_selector?('.in_technique', count: 9)
    assert page.has_content?('Method')
    assert page.has_selector?('.method', count: 2)
    #complete list of all fields
    assert page.has_content?("Binding Partners")
    assert page.has_selector?("#multiple_variation")
    assert_not page.has_checked_field?('#multiple_variation')
    assert page.has_content?("Multiple Species varied.")
    assert page.has_content?("MW")
    assert page.has_content?("Concentration")
    assert page.has_content?("varied?")
    assert page.has_content?("Molecule")
    assert page.has_field?('e.g. guest, substrate, ligand', type: 'text')
    assert page.has_field?('[start]  µmol/L', type: 'text', count: 4)
    assert page.has_field?('[end]  µmol/L', type: 'text', count: 4)
    assert page.has_content?("µM", count: 4)
    assert page.has_selector?('.single_variation_selection', count: 4)
    #assert page.has_checked_field?('#single_variation_selection_molecule') - not working, js set the check
    assert page.has_selector?('.multiple_variation_checkbox', count: 4)
    assert page.has_content?("Partner")
    assert page.has_field?('interaction_host_name')
    #assert page.has_field?('e.g. host or protein', type: 'text') - somehow not working?
    assert page.has_content?("Cofactor")
    assert page.has_field?('live search', type: 'text', count: 9)
    assert page.has_content?("Indicator")

    assert page.has_content?("Stoichiometry")
    assert page.has_selector?("input[value='1.0']", count:4) #js based the user sees 1

    #technique section can't be tested here as they are loaded later by js

    assert page.has_content?("Binding Properties")
    assert page.has_content?("Ka")
    assert page.has_selector?(".select_range", count:4)
    assert page.has_field?('binding', type: 'text')
    assert page.has_content?('±', count: 12)
    assert page.has_field?('error', type: 'text', count: 12)
    assert page.has_content?("Kd")
    assert page.has_field?('dissociation', type: 'text')
    assert page.has_content?("log Ka")
    assert page.has_field?('decadic logarithm', type: 'text')
    assert page.has_content?("ΔG")
    assert page.has_field?('free energy', type: 'text')
    assert page.has_content?("kJ mol-1", count: 2)

    assert page.has_content?("Conditions")
    assert page.has_content?("T")
    assert page.has_selector?("input[value='25.0']", count: 1)
    assert page.has_content?("°C")
    assert page.has_content?("Solubility")
    assert page.has_content?("mM", count: 5)
    # assert page.has_selector?("input[value='298']") js based
    assert page.has_content?("K ")
    assert page.has_selector?('.solvent_system', count: 4)
    assert page.has_content?("Single Solvent")
    assert page.has_content?("Buffer System")
    assert page.has_field?('interaction_buffer_name')
    assert page.has_content?("Complex Mixture")
    assert page.has_selector?('.interaction-solvent', count: 3)
    assert page.has_selector?('.interaction-additive', count: 3)
    assert page.has_content?("No Solvent")
    #assert page.has_checked_field?('interaction_solvent_system_no_solvent')  - not working, js based

    assert page.has_button?("Kinetics")
    assert page.has_button?("Thermodynamics")
    assert page.has_button?("Comment")
    assert page.has_button?("Publishing")

    assert page.has_content?("Kinetic Parameters")
    assert page.has_content?("kin")
    assert page.has_field?('association process', type: 'text')
    assert page.has_content?("M-1 s-1")
    assert page.has_checked_field?('interaction_kin_hg_unit_m-1s-1')
    assert page.has_content?("kout")
    assert page.has_field?('dissociation process', type: 'text')
    assert page.has_content?("s-1")
    assert page.has_checked_field?('interaction_kout_hg_unit_s-1')

    assert page.has_content?("Thermodynamic Parameters")
    assert page.has_content?("kcal mol-1")
    assert page.has_content?("ΔH")
    assert page.has_field?('enthalpy', type: 'text', count: 2)
    assert page.has_content?("-TΔS")
    assert page.has_field?('entropy term', type: 'text', count: 2)
    assert page.has_content?("J mol-1 K-1")
    assert page.has_content?("ΔS", count: 2)
    assert page.has_field?('entropy', type: 'text', count: 2)

    assert page.has_content?("Comment")
    assert page.has_field?('maximum 100 characters', type: 'text')

    assert page.has_content?("Review or Embargo")
    assert page.has_content?('SupraBank is providing a peer-review process so that the data entered complies the SupraBank standards.')
    assert page.has_checked_field?('interaction_embargo_false')
    assert page.has_content?("No embargo, start the review process!")
    assert_not page.has_checked_field?('interaction_embargo_true')
    assert page.has_content?("Apply an embargo! Don't start the revision process.")

    assert page.has_content?("Cross Referencing")
    assert page.has_content?('If available, please provide the DOI of the corresponding manuscript for cross-referencing.')
    assert page.has_content?("DOI")
    assert page.has_field?('reference DOI', type: 'text')
    assert page.has_content?('Please provide a reference DOI when you start the review process. Example DOI: 10.1002/anie.199013041')

    assert page.has_button?("Create Interaction")
    assert page.has_link?("Cancel")
  end

  test 'create valid and embargoed interaction' do
    visit new_interaction_path
    find('#interaction_assay_type_direct_binding_assay').set(true)
    find('#interaction_in_technique_type_fluorescence').set(true)
    find('#interaction_molecule_name').set(@molone.display_name)
    find('#interaction_host_name').set(@moltwo.display_name)
    find('#ka').set(1000)

    find('#publishing_toggle').click

    find('#interaction_embargo_true').set(true)
    find('.select_button_submit').click

    assert page.has_content?('Embargoed')
    assert page.has_content?("Interaction Scheme")

  end

  test 'try to create unvalid interactions' do
    visit new_interaction_path
    find('.select_button_submit').click
    assert_current_path "/interactions"
    assert page.has_content?("Molecule can't be blank")
    assert page.has_content?("Host can't be blank")
    assert page.has_content?("Binding constant can't be blank")
    assert page.has_content?("Binding constant must exist and be greater than 0 and finite.")
    assert page.has_content?("Doi can't be blank")
    assert page.has_content?("Assay type can't be blank")
    assert page.has_content?("In technique type can't be blank")

    visit new_interaction_path
    find('#interaction_assay_type_direct_binding_assay').set(true)
    find('#interaction_in_technique_type_fluorescence').set(true)
    find('#interaction_molecule_name').set(@molone.display_name)
    find('#interaction_host_name').set(@moltwo.display_name)
    find('#ka').set("1000")
    find('#interaction_doi').set("10.1002/anie.199013041")
    find('.select_button_submit').click
    assert page.has_content?('Submitted')
    assert page.has_content?("Interaction Scheme")
  end


#----------------edit form-----------------
  test 'consistent edit interaction form' do
    visit edit_interaction_path(@one)

    assert page.has_content?('Edit Interaction')
    assert page.has_content?('Assay')
    assert page.has_selector?('.assay-type', count: 3)
    assert page.has_content?('Technique')
    assert page.has_selector?('.in_technique', count: 9)
    assert page.has_content?('Method')
    assert page.has_selector?('.method', count: 2)
    assert page.has_content?('Binding Partners')

    assert page.has_field?('interaction_molecule_name', with: @one.molecule.display_name)
    assert page.has_field?('interaction_host_name', with: @one.host.display_name)
    assert page.has_field?('ka', with: @one.binding_constant)
    #Publishing Panel


    assert page.has_checked_field?('interaction_solvent_system_no_solvent')
    assert page.has_no_checked_field?('interaction_solvent_system_buffer_system')
    assert page.has_no_checked_field?('interaction_solvent_system_complex_mixture')
    assert page.has_no_checked_field?('interaction_solvent_system_single_solvent')

    assert page.has_checked_field?('interaction_embargo_true')

    assert page.has_button?('Update Interaction')
  end

  test 'consistent edit form for interaction_five' do
    visit edit_interaction_path(@five)

    assert page.has_content?('Edit Interaction')
    assert page.has_content?('Assay')
    assert page.has_checked_field?('interaction_assay_type_direct_binding_assay')
    assert page.has_selector?('.assay-type', count: 3)
    assert page.has_content?('Technique')
    assert page.has_checked_field?('interaction_in_technique_type_fluorescence')
    assert page.has_selector?('.in_technique', count: 9)
    assert page.has_content?('Method')
    assert page.has_selector?('.method', count: 2)

    #complete list of all fields
    assert page.has_content?("Binding Partners")
    assert page.has_selector?("#multiple_variation")
    assert_not page.has_checked_field?('#multiple_variation')
    assert page.has_content?("Multiple Species varied.")
    assert page.has_content?("MW")
    assert page.has_content?("Concentration")
    assert page.has_content?("varied?")
    assert page.has_content?("Molecule")
    assert page.has_field?('interaction_molecule_name', with: @five.molecule.display_name)
    assert page.has_field?('interaction_lower_molecule_concentration', with: @five.lower_molecule_concentration)
    assert page.has_field?('interaction_upper_molecule_concentration', with: @five.upper_molecule_concentration)
    assert page.has_content?("µM", count: 4)
    assert page.has_selector?('.single_variation_selection', count: 4)
    assert page.has_selector?('.multiple_variation_checkbox', count: 4)
    assert page.has_content?("Partner")
    assert page.has_field?('interaction_host_name', with: @five.host.display_name)
    assert page.has_field?('interaction_lower_host_concentration', with: @five.lower_host_concentration)
    assert page.has_field?('interaction_upper_host_concentration')
    assert page.has_content?("Cofactor")
    assert page.has_field?('live search', type: 'text')
    assert page.has_content?("Indicator")

    assert page.has_content?("Stoichiometry")
    assert page.has_selector?("input[value='1.0']", count:4) #js based the user sees 1

    #technique section can't be tested here as they are loaded later by js


    assert page.has_content?("Binding Properties")
    assert page.has_content?("Ka")
    assert page.has_selector?(".select_range", count:4)
    assert page.has_field?('ka', with: @five.binding_constant)
    assert page.has_content?('±', count: 12)
    assert page.has_field?('kaerror', with: @five.binding_constant_error)
    assert page.has_content?("Kd")
    assert page.has_content?("log Ka")
    assert page.has_field?('logka', with: @five.logKa)
    assert page.has_field?('logkaerror', with: @five.logka_error)
    assert page.has_content?("ΔG")
    assert page.has_field?('deltag', with: @five.deltaG)
    assert page.has_field?('deltagerror', with: @five.deltaG_error)
    assert page.has_content?("kJ mol-1", count: 2)
    #values can't be checked as they are modified by js??

    assert page.has_content?("Conditions")
    assert page.has_content?("T")
    assert page.has_selector?("input[value='25.0']", count: 1)
    assert page.has_content?("°C")
    assert page.has_content?("Solubility")
    assert page.has_field?('solubility', with: @five.solubility)
    assert page.has_content?("mM", count: 5)
    assert page.has_content?("K ")

    assert page.has_selector?('.solvent_system', count: 4)
    assert page.has_content?("Single Solvent")
    assert page.has_content?("Buffer System")
    assert page.has_field?('interaction_buffer_name')
    assert page.has_content?("Complex Mixture")
    assert page.has_selector?('.interaction-solvent', count: 3)
    assert page.has_selector?('.interaction-additive', count: 3)
    assert page.has_content?("No Solvent")
    assert page.has_checked_field?('interaction_solvent_system_single_solvent')
    assert page.has_selector?("input[value='water']")
    assert page.has_selector?("input[value='7.3']")

    assert page.has_button?("Kinetics")
    assert page.has_button?("Thermodynamics")
    assert page.has_button?("Comment")
    assert page.has_button?("Publishing")

    assert page.has_content?("Kinetic Parameters")
    assert page.has_content?("kin")
    assert page.has_selector?("input[value='45.0']")
    assert page.has_selector?("input[value='4.5']")
    assert page.has_content?("M-1 s-1")
    assert page.has_checked_field?('interaction_kin_hg_unit_m-1s-1')
    assert page.has_content?("kout")
    assert page.has_selector?("input[value='0.625']")
    assert page.has_selector?("input[value='0.063']")
    assert page.has_content?("s-1")
    assert page.has_checked_field?('interaction_kout_hg_unit_s-1')

    assert page.has_content?("Thermodynamic Parameters")
    assert page.has_content?("kcal mol-1")
    assert page.has_content?("ΔH")
    assert page.has_field?('interaction_itc_deltaH', with: @five.itc_deltaH)
    assert page.has_field?('interaction_itc_deltaH_error', with: @five.itc_deltaH_error)
    assert page.has_content?("-TΔS")
    assert page.has_field?('deltaST', with: @five.itc_deltaST)
    assert page.has_field?('interaction_itc_deltaST_error', with: @five.itc_deltaST_error)
    assert page.has_content?("J mol-1 K-1")
    assert page.has_content?("ΔS", count: 2)

    assert page.has_content?("Comment")
    assert page.has_field?('interaction_comment', with: @five.comment)

    assert page.has_content?("Review or Embargo")
    assert page.has_content?('SupraBank is providing a peer-review process so that the data entered complies the SupraBank standards.')
    assert page.has_checked_field?('interaction_embargo_false')
    assert page.has_content?("No embargo, start the review process!")
    assert_not page.has_checked_field?('interaction_embargo_true')
    assert page.has_content?("Apply an embargo! Don't start the revision process.")

    assert page.has_content?("Cross Referencing")
    assert page.has_content?('If available, please provide the DOI of the corresponding manuscript for cross-referencing.')
    assert page.has_content?("DOI")
    assert page.has_selector?("input[value='10.1021/jacs.6b07655']")
    assert page.has_content?('Example DOI: 10.1002/anie.199013041')

    assert page.has_button?('Update Interaction')
    assert page.has_link?("Cancel")

  end

  test 'edit interaction' do
    visit edit_interaction_path(@one)

    find('#interaction_assay_type_competitive_binding_assay').set(true)
    find('#interaction_in_technique_type_absorbance').set(true)
    find('#interaction_molecule_name').set(@moltwo.display_name)
    find('#interaction_host_name').set(@molthree.display_name)
    find('#ka').set(6000)

    click_button 'Update Interaction'
    assert_current_path interaction_path(@one)
    assert page.has_content?('Interaction Scheme')
    assert page.has_content?('Competive')
    assert page.has_content?('Competitive Binding Assay')
    assert page.has_content?('Absorbance')
    assert page.has_content?(@moltwo.display_name)
    assert page.has_content?(@molthree.display_name)
    assert page.has_content?("6000")
  end

end
