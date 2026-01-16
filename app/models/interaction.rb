class Interaction < ActiveRecord::Base
	include PgSearch
	include Bibliographic
	include Gerontology
	include Conversion
	include Calculations
	include Colors

	has_attached_file :bibtex, validate_media_type: false
  #validates_attachment :bibtex,   {content_type: { content_type: ['text/bibliography'] }}
	do_not_validate_attachment_file_type :bibtex
	#associations
	has_many :dataset_interactions
	has_many :datasets, :through => :dataset_interactions
  belongs_to :molecule
  validates :molecule, presence: true
  validates :comment, length: { maximum: 100 }
  belongs_to :buffer
  belongs_to :user
  belongs_to :reviewer, :class_name => 'User'
  belongs_to :host, :class_name => 'Molecule'
  validates :host, presence: true
  validates :binding_constant, presence: true, numericality: {only_float: true, greater_than: 0, message: 'must exist and be greater than 0 and finite.'}
  #validates :doi, presence: true, if: :published?
  #validates :doi, presence: true, unless: :doi_checkup?
  validates :assay_type, presence: true
  validates :in_technique_type, presence: true
	belongs_to :in_technique, polymorphic: true
	accepts_nested_attributes_for :in_technique
  belongs_to :indicator, :class_name => 'Molecule'
  belongs_to :conjugate, :class_name => 'Molecule'
	has_many :interaction_related_identifiers
	has_many :related_identifiers, :through => :interaction_related_identifiers
  has_many :interaction_solvents
  has_many :solvents, through: :interaction_solvents
  has_many :interaction_additives
  has_many :additives, through: :interaction_additives
  accepts_nested_attributes_for :interaction_additives, :allow_destroy => true
  accepts_nested_attributes_for :interaction_solvents,  :allow_destroy => true
  accepts_nested_attributes_for :solvents, :allow_destroy => true
  accepts_nested_attributes_for :additives,  :allow_destroy => true
	#callbacks
	before_save :check_volume_percent, :technique_type_humanize
  before_save :deltaG_consistency, :set_method, :convert_NaN, :buffer_transfer, :check_variation, :convert_doi_on_change, :add_citation_onchange, :check_supplement, :check_solvent_system, :calculate_unit, :set_identifer_on_change #, :clip_bibtex_on_change
	before_create :set_revision_state
	after_save :publish_when_findable, :cache_molecule_interaction
	after_initialize :solvent_additive_checkup, :if => :new_record?
	#validations
	validates :comment, length: { maximum: 100 }
	validate :check_indicator_presence
	validate :check_conjugate_presence
	#scopes
	scope :deleted, -> { where.not(deleted_at: nil) }
	scope :active, -> { where(deleted_at: nil) }
	scope :published, -> { where(published:true) }
	scope :embargoed, -> { where(embargo:true) }
	scope :not_embargoed, -> { where(embargo:false) }
	scope :created, -> { where(revision: "created") }
	scope :submitted, -> { where(revision: "submitted") }
	scope :pending, -> { where(revision: "pending") }
	scope :accepted, -> { where(revision: "accepted") }
	scope :under_revision, -> { where("embargo=? AND published=?", false, false) }
	scope :not_under_revision, -> { where("embargo=? OR published=?", true, true) }
	scope :reviewerscope, -> ( user) { where("reviewer_id=?", user) } #pgsearch
	scope :userscope, -> ( user) { where("user_id=? OR published=?", user, true) } #pgsearch
	scope :user_action, -> {where(revision: ["pending", "accepted"])}
	scope :young, -> {where("created_at > ?", 1.week.ago)}
	scope :adult, -> {where(created_at: 1.month.ago..1.week.ago)}
	scope :old, -> {where("created_at < ?", 1.month.ago)}
	scope :fresh, -> {where("updated_at > ?", 1.week.ago)}
	scope :ripe, -> {where(updated_at: 1.month.ago..1.week.ago)}
	scope :rot, -> {where("updated_at < ?", 1.month.ago)}

		pg_search_scope :search_by_doi,
                    against: [:doi, :citation],
                    using: {
                      tsearch: {dictionary: "english",
                                any_word: true,
                                prefix: true}
                    }

    pg_search_scope :search_by_names, associated_against: {
                  molecule: :names,
                  using: {
                    tsearch: {dictionary: "english",
                              any_word: true,
                              prefix: true}
                  }}




	#virtual attributes
	def publish_when_findable
		if revision == "accepted" && dataset.state == "findable"
		 self.update(revision: "published", published: true)
		end
	end
	


	def assign_primary_dataset(dataset_id)
		if dataset_id.present?
			if dataset_interactions.present?
				self.dataset_interactions.first.update(dataset_id: dataset_id)
			else
				self.dataset_interactions.build(dataset_id: dataset_id)
			end
			self.doi = dataset_interactions.first.dataset.related_identifiers.first.relatedIdentifier
		end
	end

	def cache_molecule_interaction
		molecule&.cache_interactions
		host&.cache_interactions
		indicator&.cache_interactions
		conjugate&.cache_interactions
		buffer&.cache_interactions
	end
	



	def dataset #getter
	  self.datasets&.first
	end

	def related_identifier=(relatedIdentifier)
    self.related_identifiers&.first = relatedIdentifier
  end

	def related_identifier #getter
	  self.related_identifiers&.first
	end



	def set_identifer_on_change
		if doi_changed?
			set_identifier
		end
	end


	def set_identifier
		puts cyan __method__
		logger.debug __method__
		if doi.present?
			puts "doi is present: #{doi}"
			identifier = doi
			if interaction_related_identifiers.empty?
				puts "interaction_related_identifiers are empty"
				self.interaction_related_identifiers.build
			end
			relid = RelatedIdentifier.where(relatedIdentifier: doi).first_or_create(relatedIdentifier: doi)
			puts "relid id: #{relid.id}"
			irid = interaction_related_identifiers.first
			puts 	irid
			irid.update(related_identifier_id: relid.id)
		else
			self.interaction_related_identifiers.destroy_all
		end
	end

	#methods
	def self.advanced_molecule(molecule_param)
		molecule = Molecule.find_by(display_name: molecule_param)
		self.where(molecule: molecule).or(self.where(host: molecule))
	end

	def self.advanced_host_guest(molecule_param = nil,  host_param = nil, molecule_exclusive_param=nil, host_exclusive_param=nil, host_or_param=nil)
		if molecule_param.present? && host_param.present?
			host = Molecule.where(display_name: host_param)
			molecule = Molecule.where(display_name: molecule_param)
			unless host_or_param.present?
				if molecule_exclusive_param.present? && host_exclusive_param.present?
					self.where(molecule: molecule).where(host: host)
				elsif host_exclusive_param.present?
					interactions = self.where(molecule: molecule).or(self.where(host: molecule))
					interactions.where(host: host)
				elsif molecule_exclusive_param.present?
					interactions = self.where(molecule: host).or(self.where(host: host))
					interactions.where(molecule: molecule)
				elsif molecule == host
					self.where(molecule: molecule).where(host: molecule)
				else
					interactions = self.where(molecule: molecule).or(self.where(host: molecule))
					interactions.where(molecule: host).or(interactions.where(host: host))
				end
			else
				if molecule_exclusive_param.present? && host_exclusive_param.present?
					self.where(molecule: molecule).or(self.where(host: host))
				elsif host_exclusive_param.present?
					self.where(host: host).or(self.where(host: molecule)).or(self.where(molecule: molecule))
				elsif molecule_exclusive_param.present?
					self.where(molecule: molecule).or(self.where(host: host)).or(self.where(molecule: host))
				else
					self.where(molecule: molecule).or(self.where(host: molecule)).or(self.where(host: host)).or(self.where(molecule: host))
				end
			end
		elsif molecule_param.present? || host_param.present?
			if molecule_param.present?
				molecule = Molecule.where(display_name: molecule_param)
				if molecule_exclusive_param.present?
					self.where(molecule: molecule)
				else
					self.where(molecule: molecule).or(self.where(host: molecule))
				end
			elsif host_param.present?
				host = Molecule.where(display_name: host_param)
				if host_exclusive_param.present?
					self.where(host: host)
				else
					self.where(molecule: host).or(self.where(host: host))
				end
			end
		else
			self
		end
	end

	def doi_checkup?
		embargo? || deleted_at?
	end


def calculate_unit
	a = [self.stoichometry_molecule, self.stoichometry_host]
	expo = 1-a[0]-a[1]
	if ((expo % 1) > 0.0)
		self.binding_constant_unit = "M"+"#{expo.round(1)}"
	else
		self.binding_constant_unit = "M"+"#{expo.round}"
	end
end

	def archive
		self.deleted_at = Time.now.utc
		self.embargo = nil
		self.published = nil
		self.revision = "deleted"
		self.reviewer_id = nil
		d=self.dataset
		self.comment = "Datasets have been: #{self.dataset_id}"
		self.dataset_interactions.destroy_all
		if d.present? 
			d.cache_size 
		end
	end

	def technique_type_humanize
		self.technique = in_technique_type.underscore.humanize.titleize
	end


	def valid_reviewer?(user)
		if user.present?
			if self.reviewer_id == user.id
				return true
			else
				return false
			end
		else
			return false
		end
	end


	def convert_unit
		return unit_to_html(self.binding_constant_unit)
	end
	

	def convert_to_scientific
		return num_to_scinote(self.binding_constant)
	end

	def error_to_scientific
		return num_to_scinote(self.binding_constant_error)
	end

	def set_revision_state
		if embargo
			self.revision = "created"
		else
			if reviewer.blank?
				self.reviewer = User.find_by_email("contact@suprabank.org")
			end
			self.revision = "submitted"
		end
	end

	def solvent_check
		num = (3 - self.interaction_solvents.length)
		num.times{ self.interaction_solvents.build }
	end

	def additive_check
		num = (3 - self.interaction_additives.length)
		num.times{ self.interaction_additives.build }
	end
	#

  def self.dbsearch(param)
    param.strip!
    param.downcase!
    to_send_back = (display_name_matches(param) + iupac_name_matches(param) + doi_matches(param) + preferred_abbreviation_matches(param) + display_name_host_matches(param) + iupac_name_host_matches(param) +  preferred_abbreviation_host_matches(param) + cas_matches(param) + cas_host_matches(param) + author_matches(param) + ka_matches(param)).uniq
    return nil unless to_send_back
    to_send_back
  end

	def self.advsearch(molecule_param, mol_tags_param, host_param, host_tags_param, binding_param, binding_to_param, technique_param, assay_type_param, supplement_param, doi_param, author_param, year_param, solvent_param, buffer_param, pH_param, pH_to_param, temperature_param, temperature_to_param, molecule_exclusive_param, host_exclusive_param, host_or_param)
		#
		if binding_param == "NaN"
			binding_param = nil
		end
		if binding_to_param == "NaN"
			binding_to_param = nil
		end

		if binding_param.present?
			binding_lower=true
		else
			binding_lower=false
		end

		if binding_to_param.present?
			binding_upper=true
		else
			binding_upper=false
		end


		if binding_lower && binding_upper
			binding_search = "range"
		elsif binding_lower && !binding_upper
			binding_search = "lower"
		elsif binding_upper && !binding_lower
			binding_search = "upper"
		else
			binding_search = "overall"
		end


		case binding_search
		when "range"
			to_send_back = Interaction.active.where(binding_constant: binding_param .. binding_to_param)
		when "lower"
			to_send_back = Interaction.active.where("binding_constant >= ?", binding_param )
		when "upper"
			to_send_back = Interaction.active.where("binding_constant <= ?", binding_to_param)
		when "overall"
			to_send_back = Interaction.active
		else
			to_send_back = Interaction.active
		end

		logger.debug binding_search
		logger.debug to_send_back

		if doi_param.present?
			to_send_back = to_send_back.where(doi: doi_param)
		end

		to_send_back = to_send_back.advanced_host_guest(molecule_param, host_param, molecule_exclusive_param, host_exclusive_param, host_or_param)

		if mol_tags_param.present?
			molecule = Molecule.tagged_with("#{mol_tags_param}")
			to_send_back = to_send_back.where(molecule: molecule)
		end

		if host_tags_param.present?
			host = Molecule.tagged_with("#{host_tags_param}")
			to_send_back = to_send_back.where(host: host)
		end

		if technique_param.present?
			to_send_back = to_send_back.where(technique: technique_param)
		end

		if assay_type_param.present?
			to_send_back = to_send_back.where(assay_type: assay_type_param)
		end

		if supplement_param.present?
			supplement = Molecule.find_by(display_name: supplement_param)
			if assay_type_param.blank?
				to_send_back = to_send_back.where("indicator_id = ? OR conjugate_id = ?", "#{supplement.id}", "#{supplement.id}")
			elsif assay_type_param == "Competitive Binding Assay"
				to_send_back = to_send_back.where(indicator: supplement)
			elsif assay_type_param == "Associative Binding Assay"
				to_send_back = to_send_back.where(conjugate: supplement)
			end

		end



#citation
	#author
		if author_param.present?
			to_send_back = to_send_back.author_matches(author_param)
		end
	#year
		if year_param.present?
			to_send_back = to_send_back.author_matches(year_param)
		end

#conditions
	#temperature
		if temperature_param.present?
			temp_lower=true
		else
			temp_lower=false
		end

		if temperature_to_param.present?
			temp_upper=true
		else
			temp_upper=false
		end


		if temp_lower && temp_upper
			temp_range_search=true
		elsif temp_lower && !temp_upper
			temp_lower_search=true
		elsif temp_upper && !temp_lower
			temp_upper_search=true
		end

		if temp_range_search
			to_send_back = to_send_back.where(temperature: temperature_param .. temperature_to_param)
		elsif temp_lower_search
			to_send_back =  to_send_back.where("temperature >= ?", temperature_param )
		elsif temp_upper_search
			to_send_back = to_send_back.where("temperature <= ?", temperature_to_param)
		end



	#buffer
	if buffer_param.present?
		buffer_param.strip!
		buffer_param.downcase!
		buffer = Buffer.where("lower(name) like :value OR lower(abbreviation) like :value", value:"%#{buffer_param}%")
		to_send_back = to_send_back.where(buffer: buffer)
	end

	if pH_param.present?
		ph_lower=true
	else
		ph_lower=false
	end

	if pH_to_param.present?
		ph_upper=true
	else
		ph_upper=false
	end


	if ph_lower && ph_upper
		ph_range_search=true
	elsif ph_lower && !ph_upper
		ph_lower_search=true
	elsif ph_upper && !ph_lower
		ph_upper_search=true
	end

	if ph_range_search
		to_send_back = to_send_back.where(pH: pH_param.to_f .. pH_to_param.to_f)
	elsif ph_lower_search
		to_send_back =  to_send_back.where(pH: pH_param.to_f .. 14.0)
	elsif ph_upper_search
		to_send_back = to_send_back.where(pH: 0.0 .. pH_to_param.to_f)
	end

	#solvent
	if solvent_param.present?
		solvent = Solvent.find_by(display_name: solvent_param)
		solvent_interactions= solvent.interactions.active
		to_send_back = (to_send_back & solvent_interactions) #intersection between the arrays, only those that are present in both sets
	end
		return nil unless to_send_back
    to_send_back
	end

  def self.id_matches(param)
    matches('id', param)
  end

  def self.ka_matches(param)
		Interaction.active.where(binding_constant: param)
  end

  def self.doi_matches(param)
    matches('doi', param)

  end

  def self.author_matches(param)
    matches('citation', param)
  end

  def self.cas_matches(param)
    molecule_matches('cas', param)
  end

  def self.iupac_name_matches(param)
    molecule_matches('iupac_name', param)
  end

  def self.display_name_matches(param)
    molecule_matches('display_name', param)
  end


  def self.preferred_abbreviation_matches(param)
    molecule_matches('preferred_abbreviation', param)
  end

  def self.iupac_name_host_matches(param)
    host_matches('iupac_name', param)
  end


	  def self.cas_host_matches(param)
	    host_matches('cas', param)
	  end

  def self.display_name_host_matches(param)
    host_matches('display_name', param)
  end

  def self.preferred_abbreviation_host_matches(param)
    host_matches('preferred_abbreviation', param)
  end


	def self.csv_export_molecule(param)
		require 'csv'
		file = "#{Rails.root}/public/data.csv"
		interactions = Interaction.molecule_matches("display_name", param)
		CSV.open( file, 'w' ) do |writer|
		  interactions.each do |s|
		    writer << [
			s.id,
      s.assay_type,
      s.technique,
      s.host.display_name,
      s.host.cano_smiles,
      s.molecule.display_name,
      s.molecule.cano_smiles,
      s.indicator.present? ? s.indicator.display_name : nil,
      s.indicator.present? ? s.indicator.cano_smiles : nil,
      s.conjugate.present? ? s.conjugate.display_name : nil,
      s.conjugate.present? ? s.conjugate.cano_smiles : nil,
      s.binding_constant,
      s.deltaG,
      s.temperature,
      s.itc_deltaH.present? ? s.itc_deltaH : nil,
      s.itc_deltaST.present? ? s.itc_deltaST : nil,
      s.pH.present? ? s.pH : nil,
      s.citation.present? ? s.citation : nil,
      s.doi.present? ? s.doi : nil,
      s.additives.first.present? ? s.additives.first.display_name : nil,
      s.additives.second.present? ? s.additives.second.display_name : nil,
      s.additives.third.present? ? s.additives.third.display_name : nil,
      s.solvents.first.present? ? s.solvents.first.display_name : nil,
      s.solvents.second.present? ? s.solvents.second.display_name : nil,
      s.solvents.third.present? ? s.solvents.third.display_name : nil,
      ]
		  end
		end
	end


	def self.csv_export_host(param)
		require 'csv'
		file = "#{Rails.root}/public/data.csv"
		interactions = Interaction.joins(:host).where("display_name = ?", param)
		CSV.open( file, 'w' ) do |writer|
		  interactions.each do |s|
		    writer << [
			s[:id],
      s[:assay_type],
      s[:technique],
      s.host[:display_name],
      s.host[:cano_smiles],
      s.molecule[:display_name],
      s.molecule[:cano_smiles],
      s[:binding_constant],
      s[:logKa],
      s[:deltaG]
      ]
		  end
		end
	end


  def self.molecule_matches(field_name, param)
    Interaction.joins(:molecule).where("#{field_name} ilike ?","%#{param}%")
  end

  def self.host_matches(field_name, param)
    Interaction.joins(:host).where("#{field_name} ilike ?","%#{param}%")
  end


  def self.matches(field_name, param)
    Interaction.active.where("#{field_name} ilike ?", "%#{param}%")
  end

  #belongs_to :linked_interaction_id, :class_name => 'Interaction'
  #belongs_to :additive, :class_name => 'Molecule'

	def check_doi_validity
		if doi.present?
			self.doi_validity = valid_reference_doi?(doi)
		end
	end




	def doi_validation
		if doi.present? && doi_changed?
			self.check_doi_validity
			unless doi_validity
				errors.add(:doi, "Please provide a valid DOI, see section Cross Referencing for an example. Note: Additionally appended text from citation plugins in your browser can cause problems.")
			end
		end
	end

	def interaction_dataset_availability
		if dataset_id_changed?
			cacher = Dataset.find(dataset_id)
			unless cacher.state == "draft"
				errors.add(:dataset_id, "Datasets can only be added to drafted, but not to published datasets")
			end
		end
	end
	def add_citation
    if doi.present? && doi_validity
			csl_hash = doi_request(doi)
			if csl_hash.present?
				self.citation = citation_renderer(csl_hash)
				self.crossref = csl_hash
			else
				self.citation = "Resource not found. Please verify DOI with CrossRef."
			end
    end
  end

	def add_citation_onchange
    if doi.present? && doi_changed? && doi_validity
			begin
				Timeout::timeout(0.1) {self.add_citation}
			rescue TimeoutError => e
				self.citation = "Reference will be updated soon, you provided a valid DOI!"
			end
    end
  end


	def doi_must_be_valid
    if doi.present?
        doi.gsub!(/https:\/\/doi.org\//,"")
        doi_safe = doi.gsub(/[^0-9A-Za-z^\/.-]/){|char| "%"+char.ord.to_s(16)}
        begin
          hash = Serrano.registration_agency(ids: doi_safe)[0].deep_symbolize_keys
        rescue Serrano::NotFound  => e
          hash = "Recond not found"
        rescue StandardError  => e
          hash = "Some other error"
        end
      end
    unless (hash.class == Hash)
			errors.add("CrossRef checkup", "reveals an invalid DOI, please check!")
		end
  end

	def between(x, min, max)
		return ((x-min)*(x-max) <= 0);
	end


	def deltaG_consistency
		if self.comment.present?
			comment_o = self.comment.gsub(/Please check thermodynamic parameters. /,"")
		else
			comment_o = nil
		end

		if self.deltaG.present? && self.itc_deltaH.present? && self.itc_deltaST.present?
			max = self.deltaG * 1.25
			min = self.deltaG * 0.75
			compValue = itc_deltaH + itc_deltaST
			unless self.between(compValue, min, max)
				self.comment = "Please check thermodynamic parameters. " + comment_o.to_s
			else
				self.comment = comment_o.to_s
			end
		else
			self.comment = comment_o.to_s
		end
	end

	def convert_doi_on_change
		if doi.present? && doi_changed?
			self.convert_doi
		end
	end


	def convert_doi
		if doi.present?
			pure = doi.strip
			pure = doi.gsub(/https:\/\/doi.org\//,"")
			pure = pure.gsub(/dx.doi.org\//,"")
			self.doi = pure
		end
	end


  def clone_with_associations
    clone = self.dup
    clone.molecule_id = self.host_id
    clone.host_id = self.molecule_id
    clone.linked_interaction = self.id
    clone.interaction_solvents = self.interaction_solvents
    clone.interaction_additives = self.interaction_additives
    clone.save
    return clone
  end

  def update_with_associations
    link = Interaction.find(self.linked_interaction)
    link.add_citation
    link.molecule_id = self.host_id
    link.host_id = self.molecule_id
    link.interaction_solvents = self.interaction_solvents
    link.interaction_additives = self.interaction_additives

    link.save
    return link
  end

	def self.duplicate(interaction_id, user_id, dataset_id=nil)
		stem = Interaction.find(interaction_id)
		if dataset_id.present?
			dataset = Dataset.find(dataset_id)
			if dataset.state == "findable"
				interaction = stem.deep_clone include: [ :interaction_solvents, :interaction_additives], skip_missing_associations: true
			else
				interaction = stem.deep_clone include: [ :interaction_solvents, :interaction_additives, :dataset_interactions], skip_missing_associations: true
			end
		else
			interaction = stem.deep_clone include: [ :interaction_solvents, :interaction_additives], skip_missing_associations: true
		end
		interaction.published = false
		interaction.embargo = true
		interaction.revision = "created"
    interaction.user = User.find(user_id)
		return interaction
  end


  def solvent_attributes=(solvent_attributes)
    solvent_attributes.each do |attributes|
      solvents.build(attributes)
    end
  end

#Task: move all getter and setters to model
  def molecule_name
    self.molecule.try(:display_name)
  end

  def molecule_name=(name)
    self.molecule = Molecule.find_by(display_name: name) if name.present?
  end

	def dataset_title
		self.dataset.try(:title)
	end

	def dataset_title=(title)
		self.dataset = Dataset.find_by(title: title) if title.present?
	end

	def dataset_id
		self.dataset.try(:id)
	end

	def dataset_id=(id)
		self.dataset = Dataset.find_by(id: id) if id.present?
	end



  def host_name
    self.host.try(:display_name)
  end

  def host_name=(name)
    self.host = Molecule.find_by(display_name: name) if name.present?
  end

  def indicator_name
    self.indicator.try(:display_name)
  end

  def indicator_name=(name)
    self.indicator = Molecule.find_by(display_name: name) if name.present?
  end

  def conjugate_name
    self.conjugate.try(:display_name)
  end

  def conjugate_name=(name)
    self.conjugate = Molecule.find_by(display_name: name) if name.present?
  end

  def buffer_name
    self.buffer.try(:name)
  end

	def buffer_name=(name)
		if name.present?
			self.buffer = Buffer.find_by(name: name)
		else
			self.buffer = nil
		end
	end


  def additive_name
    additives.try(:id)
  end

  def additive_name=(name)
    self.additives << Additive.find_by(display_name: name) if name.present?
  end

  def second_additive
    additives.try(:id)
  end

  def second_additive=(name)
    self.additives << Additive.find_by(display_name: name) if name.present?
  end

  def third_additive
    additives.try(:id)
  end

  def third_additive=(name)
    self.additives << Additive.find_by(display_name: name) if name.present?
  end

  def fourth_additive
    additives.try(:id)
  end

  def fourth_additive=(name)
    self.additives << Additive.find_by(display_name: name) if name.present?
  end

  def solvent_additive_checkup
      nsolvent = 3 - self.interaction_solvents.size
      nadditives = 3 - self.interaction_additives.size
      unless nsolvent <= 0
        nsolvent.times{self.interaction_solvents.build}
      end
      unless nadditives <= 0
        nadditives.times{self.interaction_additives.build}
      end

  end




	def check_indicator_presence
		if assay_type == "Competitive Binding Assay" && indicator.nil?
			errors.add(:indicator, "can't be blank")
		end
	end

	def check_conjugate_presence
		if assay_type == "Associative Binding Assay" && conjugate.nil?
			errors.add(:conjugate, "Cofactor can't be blank")
		end
	end


	def solvent_sanitization(solvent_system, solvent)
		case self.solvent_system
		when "Single Solvent"
			self.buffer_name=nil
			self.interaction_solvents.destroy_all
			self.interaction_solvents.build(solvent: solvent_name(solvent))
			self.additives.destroy_all
			self.ionic_strength = nil
		when "No Solvent"
			self.ionic_strength = nil
			self.buffer_name=nil
			self.pH=nil
			self.interaction_solvents.destroy_all
			self.interaction_additives.destroy_all
		when "Complex Mixture"
			# self.interaction_solvents.where(solvent_id:nil).delete_all
			self.buffer_name=nil
		end
	end



	def hierachical_sanitization
		self.check_supplement
	end





		def check_supplement
			case self.assay_type
			when "Competitive Binding Assay"
				self.conjugate = nil
			when "Associative Binding Assay"
				self.indicator = nil
			when "Direct Binding Assay"
				self.indicator = nil
				self.conjugate = nil

			end
		end



		def bibtex_export
			url = doi_bibtex(self.doi)
			return url
		end

		def ris_export
			url = bib_to_ris(self.bibtex.path, self.doi)
			return url
		end

		def enw_export
			url = bib_to_enw(self.bibtex.path, self.doi)
			return url
		end

		def citation_pdf
			if self.crossref.present?
				pdf_link self.crossref
			else
				nil
			end
		end



		def clip_bibtex_on_change
			if doi.present? && doi_changed?
				begin
				Timeout::timeout(3) {self.clip_bibtex}
				rescue StandardError => e
					self.bibtex = nil
				end
			end
		end

		def clip_bibtex
			if doi.present?
				bib_file_path = doi_bibtex(self.doi)
				logger.debug bib_file_path
				if bib_file_path.present?
					bib_file = File.open(bib_file_path)
					self.bibtex = bib_file
				end
			end
		end



		def add_crossref
			if doi.present? && doi_validity
				csl_hash = doi_request(doi)
				if csl_hash.present?
					self.citation = citation_renderer(csl_hash)
					self.crossref = csl_hash
				else
					self.citation = "Resource not found. Please verify DOI with CrossRef."
				end
			end
		end

		private

    def set_method
      if self.assay_type == "Competitive Binding Assay"
        self.method = "Competitive"
      else
        self.method = "Direct"
      end
    end

		def check_variation
		 if self.technique != "Isothermal Titration Calorimetry"
			case self.variation
			when "molecule"
			  self.upper_host_concentration = nil
				self.upper_conjugate_concentration = nil
				self.upper_indicator_concentration = nil
			when "host"
				self.upper_molecule_concentration = nil
				self.upper_conjugate_concentration = nil
				self.upper_indicator_concentration = nil
			when "indicator"
				self.upper_molecule_concentration = nil
				self.upper_conjugate_concentration = nil
				self.upper_host_concentration = nil
			when "conjugate"
				self.upper_molecule_concentration = nil
				self.upper_indicator_concentration = nil
				self.upper_host_concentration = nil
			end
		 end
		end




    def convert_NaN

      if self.logka_error == "NaN"
        self.logka_error = nil
      end
      if self.binding_constant_error == "NaN"
        self.binding_constant_error = nil
      end
      if self.deltaG_error == "NaN"
        self.deltaG_error = nil
      end

    end

		def check_volume_percent
			if solvent_system == "Single Solvent"

			end
		end


    def check_solvent_system
      case self.solvent_system
      when "Single Solvent"
				self.buffer_name=nil
				self.interaction_solvents.where(solvent_id:nil).delete_all
				self.interaction_additives.delete_all
				self.ionic_strength = nil
      when "No Solvent"
        self.buffer_name=nil
				self.pH=nil
				self.interaction_solvents.delete_all
				self.interaction_additives.delete_all
				self.ionic_strength = nil
      when "Complex Mixture"
        self.interaction_solvents.where(solvent_id:nil).delete_all
				self.buffer_name=nil
				self.interaction_additives.where(additive_id:nil).delete_all
      end
    end

    def buffer_transfer
      if self.solvent_system == "Buffer System"
        if self.buffer.present?
          if self.buffer.pH.present?
            self.pH = self.buffer.pH
          end
          if self.buffer.conc.present?
            self.ionic_strength = self.buffer.conc
					else
						self.ionic_strength = nil
          end
          self.interaction_solvents.delete_all
          self.solvents.delete_all
          self.interaction_additives.delete_all
          self.additives.delete_all
          # nbuffer_additives = self.buffer.buffer_additives.size
          # nbuffer_additives.times{self.interaction_additives.build}
          # nbuffer_solvents = self.buffer.buffer_solvents.size
          # nbuffer_solvents.times{self.interaction_solvents.build}
          nb = 0
          for buffer_additive in self.buffer.buffer_additives.where.not(additive_id:nil) do
            self.interaction_additives.build
            self.interaction_additives[nb].additive = buffer_additive.additive
            self.interaction_additives[nb].concentration = buffer_additive.concentration
            nb = nb + 1
          end
          ns = 0
          for buffer_solvent in self.buffer.buffer_solvents.where.not(solvent_id:nil) do
            self.interaction_solvents.build
            self.interaction_solvents[ns].solvent = buffer_solvent.solvent
            self.interaction_solvents[ns].volume_percent = buffer_solvent.volume_percent
            ns = ns + 1
          end

          nsolvent = 3 - self.interaction_solvents.size
          nadditives = 3 - self.interaction_additives.size

          unless nsolvent <= 0
            nsolvent.times{self.interaction_solvents.build}
          end
          unless nadditives <= 0
            nadditives.times{self.interaction_additives.build}
          end

        end
      end
    end


		def self.csv_export(param)
		  require 'csv'
		  file = "#{Rails.root}/tmp/csv/interactions.csv"
		  csvinteractions = Interaction.host_matches("display_name", param)
		  CSV.open(
		    file,
		    'w',
		    :write_headers=> true,
		    :headers => [
		      "Interaction SBID",
		      "AssayType",
		      "Technique",
		      "Molecule",
		      "Molecule SMILES",
		      "Molecule charge",
		      "Molecule h_bond_donor_count",
		      "Molecule h_bond_acceptor_count",
		      "Molecule tpsa",
		      "Molecule ertl_tpsa",
		      "Molecule x_log_p",
		      "Molecule cheng_xlogp3",
		      "Host",
		      "Host SMILES",
					"Host charge",
					"Host h_bond_donor_count",
					"Host h_bond_acceptor_count",
					"Host tpsa",
					"Host ertl_tpsa",
					"Host x_log_p",
					"Host cheng_xlogp3",
		      "Indicator",
		      "Indicator SMILES",
					"Indicator charge",
					"Indicator h_bond_donor_count",
					"Indicator h_bond_acceptor_count",
					"Indicator tpsa",
					"Indicator ertl_tpsa",
					"Indicator x_log_p",
					"Indicator cheng_xlogp3",
		      "Cofactor",
		      "Cofactor SMILES",
					"Cofactor charge",
					"Cofactor h_bond_donor_count",
					"Cofactor h_bond_acceptor_count",
					"Cofactor tpsa",
					"Cofactor ertl_tpsa",
					"Cofactor x_log_p",
					"Cofactor cheng_xlogp3",
		      "Binding constant",
		      "DeltaG kJ mol-1",
		      "Temperature °C",
		      "DeltaH kJ mol-1",
		      "-TDeltaS kJ mol-1",
		      "pH",
		      "Citation",
		      "DOI",
		      "Additive_1",
		      "Additive_2",
		      "Additive_3",
		      "Solvent_1",
		      "Solvent_2",
		      "Solvent_3"
		    ]
		    ) do |writer|
		    csvinteractions.each do |s|
		      writer << [
		        "https://suprabank.org/interactions/" + s.id.to_s,
		        s.assay_type,
		        s.technique,
		        s.molecule.display_name,
		        s.molecule.iso_smiles,
		        s.molecule.charge,
		        s.molecule.h_bond_donor_count,
		        s.molecule.h_bond_acceptor_count,
		        s.molecule.tpsa,
		        s.molecule.ertl_tpsa,
		        s.molecule.x_log_p,
		        s.molecule.cheng_xlogp3,
		        s.host.display_name,
		        s.host.iso_smiles,
		        s.host.charge,
		        s.host.h_bond_donor_count,
		        s.host.h_bond_acceptor_count,
		        s.host.tpsa,
		        s.host.ertl_tpsa,
		        s.host.x_log_p,
		        s.host.cheng_xlogp3,
						s.indicator.present? ? s.indicator.display_name : nil,
						s.indicator.present? ? s.indicator.iso_smiles : nil,
						s.indicator.present? ? s.indicator.charge : nil,
						s.indicator.present? ? s.indicator.h_bond_donor_count : nil,
						s.indicator.present? ? s.indicator.h_bond_acceptor_count : nil,
						s.indicator.present? ? s.indicator.tpsa : nil,
						s.indicator.present? ? s.indicator.ertl_tpsa : nil,
						s.indicator.present? ? s.indicator.x_log_p : nil,
						s.indicator.present? ? s.indicator.cheng_xlogp3 : nil,
						s.conjugate.present? ? s.conjugate.display_name : nil,
						s.conjugate.present? ? s.conjugate.iso_smiles : nil,
						s.conjugate.present? ? s.conjugate.charge : nil,
						s.conjugate.present? ? s.conjugate.h_bond_donor_count : nil,
						s.conjugate.present? ? s.conjugate.h_bond_acceptor_count : nil,
						s.conjugate.present? ? s.conjugate.tpsa : nil,
						s.conjugate.present? ? s.conjugate.ertl_tpsa : nil,
						s.conjugate.present? ? s.conjugate.x_log_p : nil,
						s.conjugate.present? ? s.conjugate.cheng_xlogp3 : nil,
		        s.binding_constant,
		        s.deltaG,
		        s.temperature,
		        s.itc_deltaH.present? ? s.itc_deltaH : nil,
		        s.itc_deltaST.present? ? s.itc_deltaST : nil,
		        s.pH.present? ? s.pH : nil,
		        s.citation.present? ? s.citation : nil,
		        s.doi.present? ? s.doi : nil,
		        s.additives.first.present? ? s.additives.first.display_name : nil,
		        s.additives.second.present? ? s.additives.second.display_name : nil,
		        s.additives.third.present? ? s.additives.third.display_name : nil,
		        s.solvents.first.present? ? s.solvents.first.display_name : nil,
		        s.solvents.second.present? ? s.solvents.second.display_name : nil,
		        s.solvents.third.present? ? s.solvents.third.display_name : nil,
		        ]
		    end
		  end
		  return file
		end

		# create_table "molecules", force: :cascade do |t|
		# 	t.string   "inchikey"
		# 	t.string   "inchistring"
		# 	t.float    "molecular_weight"
		# 	t.float    "volume_3d"
		# 	t.float    "tpsa"
		# 	t.float    "complexity"
		# 	t.string   "sum_formular"
		# 	t.string   "names",                            default: [],                 array: true
		# 	t.string   "iupac_name"
		# 	t.string   "display_name"
		# 	t.string   "cas"
		# 	t.float    "conformer_count_3d"
		# 	t.float    "bond_stereo_count"
		# 	t.float    "atom_stereo_count"
		# 	t.float    "h_bond_donor_count"
		# 	t.float    "h_bond_acceptor_count"
		# 	t.float    "x_log_p"
		# 	t.float    "charge"
		# 	t.string   "cano_smiles"
		# 	t.string   "iso_smiles"
		# 	t.string   "fingerprint_2d"
		# 	t.boolean  "is_partial",                       default: false, null: false
		# 	t.datetime "created_at",                                       null: false
		# 	t.datetime "updated_at",                                       null: false
		# 	t.datetime "deleted_at"
		# 	t.string   "pubchem_link"
		# 	t.integer  "cid"
		# 	t.string   "svg_file_name"
		# 	t.string   "svg_content_type"
		# 	t.integer  "svg_file_size",          limit: 8
		# 	t.datetime "svg_updated_at"
		# 	t.string   "png_file_name"
		# 	t.string   "png_content_type"
		# 	t.integer  "png_file_size",          limit: 8
		# 	t.datetime "png_updated_at"
		# 	t.string   "mdl_string"
		# 	t.string   "preferred_abbreviation"
		# 	t.integer  "user_id"
		# 	t.string   "cdx_file_name"
		# 	t.string   "cdx_content_type"
		# 	t.integer  "cdx_file_size",          limit: 8
		# 	t.datetime "cdx_updated_at"
		# 	t.string   "pdb_id"
		# 	t.float    "total_structure_weight"
		# 	t.integer  "atom_count"
		# 	t.integer  "residue_count"
		# 	t.text     "pdb_descriptor"
		# 	t.text     "pdb_title"
		# 	t.text     "pdb_keywords"
		# 	t.integer  "molecule_type",                    default: 0
		# 	t.float    "cheng_xlogp3"
		# 	t.float    "ertl_tpsa"
		# end

end
