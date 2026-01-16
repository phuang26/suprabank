require 'test_helper'

class AdditiveEditTest < Capybara::Rails::TestCase
  include Warden::Test::Helpers
  def setup
    @one = additives :additive_one
    @two = additives :additive_two
    @user = users :user_one
    login_as(@user)
  end


  test 'normal user complete additive search page' do

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

  test 'normal user search a additive' do
    visit additives_path
    fill_in 'search_param', with: 'sodium chloride'
    click_button 'Search'
    assert page.has_content?(@one.display_name)
    assert page.has_content?(@two.display_name)
  end

  test 'normal user try to edit additive' do
    visit additive_path(@one)
    assert_not page.has_link?('Edit', :exact => true)
    assert_not page.has_link?('Delete', :exact => true)
  end


end
