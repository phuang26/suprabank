require 'test_helper'

class InteractionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @interaction_one = interactions(:interaction_one)
    @interaction = Interaction.new
    @molone = molecules :molecule_one
    @moltwo = molecules :molecule_two
  end

  test  "interaction_one should be valid" do
    assert @interaction_one.valid?
  end

  test  "interaction_two should be valid" do
    assert interactions(:interaction_two).valid?
  end

  test 'doi must be present when published' do
    @interaction_one.published=true
    @interaction_one.doi = '  '
    assert_not @interaction_one.valid?
  end


  test 'minimal reporting' do
    interaction = Interaction.new
    interaction.molecule = @molone
    interaction.host = @moltwo
    interaction.in_technique_type = "Fluorescence"
    interaction.assay_type = "Direct Binding Assay"
    interaction.method = "Direct"
    interaction.binding_constant = 1000
    interaction.solvent_system = "No Solvent"
    interaction.published = false
    interaction.embargo = true
    interaction.revision = "created"
    assert interaction.valid?
  end
  # test 'check method' do
  #   @interaction_one.set_method
  #   assert @interaction_one.method == "Direct"
  # end

  # test  "interaction_one should be valid" do
  #   assert @interaction_one.valid?
  # end

end
