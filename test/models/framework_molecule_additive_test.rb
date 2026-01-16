require "test_helper"

class FrameworkMoleculeAdditiveTest < ActiveSupport::TestCase
  def framework_molecule_additive
    @framework_molecule_additive ||= FrameworkMoleculeAdditive.new
  end

  def test_valid
    assert framework_molecule_additive.valid?
  end
end
