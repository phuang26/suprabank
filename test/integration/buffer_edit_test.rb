require 'test_helper'

class BufferEditTest < Capybara::Rails::TestCase
  include Warden::Test::Helpers
  def setup
    @one = buffers :buffer_three
    @two = buffers :buffer_two
    @user = users :user_one
    login_as(@user)
  end
#----------Search buffer -------------------------

  test 'logged in complete buffer search page' do
    visit buffers_path

    assert page.has_content?("Search for Buffers")
    assert page.has_content?("Name")
    assert page.has_field?('Enter (part of) buffer name, e.g. phosphate', type: 'text')
    assert page.has_content?("pH")
    assert page.has_field?('pH value', type: 'text')
    assert page.has_content?("Conc/mM")
    assert page.has_field?('total concentration in mM', type: 'text')
    assert page.has_link?("Show all SupraBank buffers")
    assert page.has_link?("New")

    click_button 'Search'
    assert page.has_content?("You need to put some content")

  end

  test 'logged in search a buffer' do
    visit buffers_path

    fill_in 'search_param', with: 'phosphate'
    click_button 'Search'

    assert page.has_content?("Info")
    assert page.has_content?("Abbreviation")
    assert page.has_content?("Name")
    assert page.has_content?("pH")
    #assert page.has_content?("M / g/mol")
    assert page.has_content?("C / mM")
    assert page.has_content?("Interactions")
    assert page.has_content?("Updated")
    assert page.has_content?(@one.name)

  end

  test 'logged in search a unvalid buffer' do
    visit buffers_path

    fill_in 'search_param', with: 'xyz'
    click_button 'Search'
    assert page.has_content?("Nothing found in the database Buffers")
    assert_not page.has_content?("Abbreviation")

  end

  test 'logged in show all buffers' do
    visit buffers_path

    click_link 'Show all SupraBank buffers'
    assert_current_path listing_buffers_path

    assert page.has_content?("Info")
    assert page.has_content?("Abbreviation")
    assert page.has_content?("Name")
    assert page.has_content?("pH")
    #assert page.has_content?("M / g/mol")
    assert page.has_content?("C / mM ")
    assert page.has_content?("Interactions")
    assert page.has_content?("Updated")
    assert page.has_content?(@one.name)
    assert page.has_content?("BT")
    assert page.has_content?("BO")
  end

#--------new buffer---------------


  test 'logged in complete create new buffer page' do
    visit new_buffer_path

    assert page.has_content?('New Buffer')
    assert page.has_content?("A buffer (short for buffer solution) commonly is an aqueous solution consisting of a mixture of a weak acid and its conjugate base (or vice versa) which are the additives to the solvent. A duplicate check is performed automatically, see table below.")
    assert page.has_content?("Name")
    assert page.has_field?('e.g. 10 mM sodium phosphate buffer pH-7.0', type: 'text')
    assert page.has_content?("Abbreviation")
    assert page.has_field?('e.g. 10 mM phosphate pH-7.0', type: 'text')
    assert page.has_content?("pH")
    assert page.has_field?('e.g. 7.0', type: 'text')
    assert page.has_content?("Total concentration")
    assert page.has_field?('is calculated if additives given', type: 'text')
    assert page.has_content?("mM")

    assert page.has_content?('Recipe')
    assert page.has_content?("Solvents")
    assert page.has_content?("Vol%")
    assert page.has_content?("Additives")
    assert page.has_content?("Conc.")
    assert page.has_field?('live search', type: 'text', count: 7)
    assert page.has_selector?('.first_solvent_name', count: 3)
    assert page.has_selector?('.first_additive_name', count: 4)

    assert page.has_content?('Source of Additives Concentrations')
    assert page.has_content?("Real concentrations (from measurement or retrieved from paper)")
    assert page.has_content?("Estimated concentrations (lack of information in paper)")
    assert page.has_content?("Buffers on SupraBank based on the given name. Please check before creation of a new entry.")
  end


  test 'logged in create unvalid buffer' do
    visit new_buffer_path
    click_button("Create Buffer")
    assert page.has_content?('Buffer could not be created. The name needs to be unique. Please compare to the table below and rename your buffer by adding e.g. an "A" at the end of the name.')

    visit new_buffer_path
    find('#buffer_name').set('Phosphate')
    #assert page.has_content?("PO4") #showing the duplicate in table, not possible to test as it is js-based
    click_button("Create Buffer")
    assert page.has_content?('Buffer could not be created. The name needs to be unique. Please compare to the table below and rename your buffer by adding e.g. an "A" at the end of the name.')

    visit new_buffer_path
    find('#buffer_name').set('test buffer')
    click_button("Create Buffer")
    assert_current_path buffer_path(Buffer.last)
    assert page.has_content?('Buffer was successfully created.')
    assert page.has_content?('Buffer | test buffer')
    assert page.has_link?('Edit')
    assert page.has_link?('Back')

    click_link('Edit')
    assert_current_path edit_buffer_path(Buffer.last)
    find('#buffer_name').set('Phosphate')
    click_button("Update Buffer")
    assert_current_path buffer_path(Buffer.last)
    assert_not page.has_content?('Buffer | ') #this means that the page is not properly loaded

  end


#--------buffer overview---------------



  test 'overview page of buffer_one complete' do

    visit buffer_path(@one)

    assert page.has_content?('Buffer | Phosphate')

    assert page.has_content?('Solvation')
    assert page.has_content?('Solvent')
    assert page.has_content?('Vol %')
    assert page.has_content?('methanol')
    assert page.has_content?('70.0')
    assert page.has_content?('water')
    assert page.has_content?('30.0')

    assert page.has_content?('Additives')
    assert page.has_content?('Additive')
    assert page.has_content?('Concentration')
    assert page.has_content?('sodium chloride')
    assert page.has_content?('20.0 mM')
    assert page.has_content?('sodium iodide')
    assert page.has_content?('30.0 mM')

    assert page.has_content?('Properties')
    assert page.has_content?('Total concentration')
    assert page.has_content?('50.0 mM')
    assert page.has_content?('pH')
    assert page.has_content?('7.0')
    assert page.has_content?('Source of concentration of additives')
    assert page.has_content?('real')

    assert page.has_link?('Back', :exact => true)
    assert page.has_link?('Edit', :exact => true)

    click_link('Edit')
    assert_current_path edit_buffer_path(@one)
    find('#buffer_pH').set('7.5')
  end

  test 'change buffer_two complete' do

    visit edit_buffer_path(@two)
    find('#buffer_pH').set('7.5')
    click_button("Update Buffer")

    assert_current_path buffer_path(@two)
    assert page.has_content?('Buffer was successfully updated.')
    assert page.has_content?('Buffer | Buffer Two')
    assert page.has_content?('7.5')
  end
end
