class Buffer < ActiveRecord::Base
  has_many :interactions
  has_many :buffer_additives, dependent: :destroy
  has_many :additives , through: :buffer_additives
  has_many :buffer_solvents, dependent: :destroy
  has_many :solvents, through: :buffer_solvents
  belongs_to :user
  accepts_nested_attributes_for :buffer_additives, :allow_destroy => true
  accepts_nested_attributes_for :buffer_solvents,  :allow_destroy => true
  accepts_nested_attributes_for :solvents, :allow_destroy => true
  accepts_nested_attributes_for :additives,  :allow_destroy => true
  validates :name, presence: true, uniqueness: {case_sensitive: false}
  after_save :update_interactions, :cache_interactions

  def update_interactions
    self.interactions.active.each{|interaction| interaction.save}
  end

  def cache_interactions
    self.update_column(:interactions_count, self.interactions.count)
  end

  def self.dbsearch(name_param, pH_param, conc_param)

    to_send_back = Buffer.all

    unless name_param.nil?||name_param.blank?
       name_param.strip!
       name_param.downcase!


       to_send_back = Buffer.where("lower(name) like :value OR lower(abbreviation) like :value", value:"%#{name_param}%")

    end

    unless pH_param.nil?||pH_param.blank?
      to_send_back = to_send_back.where(pH: pH_param)
    end

    unless conc_param.nil?||conc_param.blank?
       to_send_back = to_send_back.where(conc: conc_param)
    end


    return nil unless to_send_back
    to_send_back
  end

  def full_name
    return "#{name}|#{solvents.first.display_name}".strip if (name||solvents)
    'Anonymous'
  end

  def no_solvent_present
     self.buffer_solvents.where(solvent_id:nil).size != self.buffer_solvents.size
  end


  def additive_name
    additive.try(:name)
  end

  def additive_name=(name)
    self.additive = Additive.find_by(display_name: name) if name.present?
  end



end
