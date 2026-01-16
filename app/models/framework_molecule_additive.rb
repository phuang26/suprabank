class FrameworkMoleculeAdditive < ActiveRecord::Base
  belongs_to :framework_molecule
  belongs_to :additive
end
