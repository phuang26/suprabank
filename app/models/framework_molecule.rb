class FrameworkMolecule < ActiveRecord::Base
  belongs_to :molecule
  belongs_to :framework
  has_many :framework_molecule_additives
  has_many :additives, through: :framework_molecule_additives

  def framework_code
    self.framework.try(:code)
  end

  def additive
    self.framework_molecule_additives&.first&.additive
  end
  
end
