require 'test_helper'

class SolventEditTest < Capybara::Rails::TestCase
  include Warden::Test::Helpers
  def setup
    @one = solvents :solvent_one
    @two = solvents :solvent_two
    @three = solvents :solvent_three
    @four = solvents :solvent_four
    @user = users :user_one
    login_as(@user)
  end


  test 'normal user complete solvent search page' do

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

  test 'normal user search a solvent' do
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

  test 'normal user try to edit solvent' do
    visit solvent_path(@one)
    assert_not page.has_link?('Edit', :exact => true)
    assert_not page.has_link?('Delete', :exact => true)
  end


end
