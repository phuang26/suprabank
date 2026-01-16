require 'test_helper'

class InteractionShowTest < Capybara::Rails::TestCase

  def setup
    @one = interactions :interaction_one
    @two = interactions :interaction_two
    @published = interactions :interaction_published
  end

  test 'latest entries list' do
    visit interactions_path

    assert page.has_content?('Latest 200 Interactions published on the SupraBank')

    assert has_link?("Create a new Interaction")
    click_link("Create a new Interaction")
    assert_current_path new_user_session_path
    fill_in "Email", with: "normaluser@mailinator.com"
    fill_in "Password", with: "123456"
    click_button("Log in")
    assert_current_path new_interaction_path

  end

  test 'unpublished interaction overview' do
    visit interaction_path(@one)
    assert page.has_content?('You are not authorized to perform this action.')
    assert_current_path root_path
  end

  test 'published interaction overview' do
    visit interaction_path(@published)

    assert page.has_content?('Interaction')
    assert page.has_content?('Interaction Scheme')
    assert page.has_content?('Binding Properties')
    assert page.has_content?('Determination Specification')
    assert page.has_content?('Solvation Properties')
    assert page.has_content?(@published.molecule.display_name)
    assert page.has_content?(@published.host.display_name)

    assert_not page.has_link?('Edit', :exact => true)
    assert_not page.has_link?('Delete')
  end




end
