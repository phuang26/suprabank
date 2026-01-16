require 'test_helper'

class SolventTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    #skip "worked"
    @solvent = Solvent.new_from_name("dichloromethane")
    # @solvent.display_name="ethanol"
    # @solvent.iso_smiles="CCO"
  end

  test  "solvent should be present" do
    assert @solvent.present?
  end

  test  "display_name should be present" do
    assert @solvent.display_name.present?
  end

  test  "iso_smiles should be present" do
    assert @solvent.iso_smiles.present?
  end


  test  "solvent should be valid" do

    assert @solvent.valid?
  end
end
