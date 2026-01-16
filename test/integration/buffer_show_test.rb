require 'test_helper'

class BufferShowTest < Capybara::Rails::TestCase

  def setup
    @one = buffers :buffer_three
  end

#----------Search buffer -------------------------

  test 'complete buffer search page' do
    visit buffers_path

    assert page.has_content?("Search for Buffers")
    assert page.has_content?("Name")
    assert page.has_field?('Enter (part of) buffer name, e.g. phosphate', type: 'text')
    assert page.has_content?("pH")
    assert page.has_field?('pH value', type: 'text')
    assert page.has_content?("Conc/mM")
    assert page.has_field?('total concentration in mM', type: 'text')
    assert page.has_link?("Show all SupraBank buffers")
    assert_not page.has_link?("New")

    click_button 'Search'
    assert page.has_content?("You need to put some content")

  end

  test 'search a buffer' do
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
    #assert page.has_content?("No data available in table") probably javascript

  end

  test 'search a unvalid buffer' do
    visit buffers_path

    fill_in 'search_param', with: 'xyz'
    click_button 'Search'
    assert page.has_content?("Nothing found in the database Buffers")
    assert_not page.has_content?("Abbreviation")

  end

  test 'show all buffers' do
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
    #assert page.has_content?("No data available in table") probably javascript

  end

#--------new buffer---------------

  test 'try to create new buffer' do
    visit new_buffer_path

    assert page.has_content?('You need to sign in or sign up before continuing.')
    assert_current_path new_user_session_path
    fill_in "Email", with: "normaluser@mailinator.com"
    fill_in "Password", with: "123456"
    click_button("Log in")
    assert_current_path new_buffer_path
    assert page.has_content?('Signed in successfully.')
    assert page.has_content?('New Buffer')

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
    assert_not page.has_link?('Edit', :exact => true)
  end

end
