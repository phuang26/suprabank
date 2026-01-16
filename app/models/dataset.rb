class Dataset < ActiveRecord::Base
  include Datacite
  include Bibliographic
  include Colors
  #paperclip
  has_attached_file :bibtex, validate_media_type: false
  do_not_validate_attachment_file_type :bibtex
  has_attached_file :img, styles: { medium: '300x300>', thumb: '100x100>' }, default_url: '/images/:style/missing.png'
  validates_attachment_content_type :img, content_type: ['image/jpeg', 'image/gif', 'image/png', 'image/svg+xml', 'text/plain']
  acts_as_taggable_on :subjects
  has_many :dataset_users
  has_many :users, :through => :dataset_users
  has_many :dataset_interactions, :dependent => :destroy
  has_many :interactions, :through => :dataset_interactions
  has_many :dataset_creators
  has_many :creators, :through => :dataset_creators
  has_many :dataset_contributors
  has_many :contributors, :through => :dataset_contributors
  has_many :dataset_related_identifiers, :dependent => :destroy
  has_many :related_identifiers, :through => :dataset_related_identifiers

  accepts_nested_attributes_for :dataset_creators, allow_destroy: true
  accepts_nested_attributes_for :creators

  accepts_nested_attributes_for :dataset_contributors, allow_destroy: true
  accepts_nested_attributes_for :contributors


  accepts_nested_attributes_for :dataset_related_identifiers, allow_destroy: true
  accepts_nested_attributes_for :related_identifiers

  #validations
  validates_associated :related_identifiers
  validates_associated :dataset_related_identifiers
  validates :title, presence: true
  validates :title, uniqueness: true
  validates :primary_reference, uniqueness: true, if: -> {primary_reference.present?}
  #validate :primary_reference_must_be_unique

  #callbacks
  after_initialize :related_identifiers_build, :if => :new_record?
  after_initialize :generate_preliminary_doi, :if => :new_record?

  before_save :sanitize_primary_reference
  before_save :initialize_contributors
  before_save :generate_publication_year, :generate_alternateIdentifier, :rights_update
  after_save :update_info
  before_save :clip_bibtex
  before_save :curation_status
  before_save :cache_toc_graphic_on_change
  before_destroy :destroy_on_datacite
  after_save :set_primary_identifier, :initialize_revision, :cache_size, :generate_size, :update_dois, :empty_dataset_creator, :cache_img_url #, :empty_dataset_contributor
  #before_save :creators_update
  #after_save :update_info
  #virtuel attributes
  #scopes
  scope :findable, -> { where(state: "findable") }
  scope :registered, -> { where(state: "registered") }
  scope :drafted, -> { where(state: "draft") }
  scope :curated, -> { where(:label => "curated")}
  # Ex:- scope :active, -> {where(:active => true)}
  scope :editable, -> { where(state: "draft").or(where(state: "registered")) }
  scope :datacite_drafted, -> { where("datacite->'data'->'attributes'->>'state' = ?", 'draft')} 
  scope :datacite_data_presence, -> { where("(datacite->'data') is not null")}
  scope :datacite_data_absence, -> { where("(datacite->'data') is null")}
  
  # Ex:- scope :active, -> {where(:active => true)}
  # Ex:- scope :active, -> {where(:active => true)}

  enum scholarArticleState: {
    mere_dataset: 0,
    genesis: 1,
    submission: 2,
    published: 3
  }
  

  def cache_toc_graphic_on_change
    if primary_reference_changed?
      cache_toc_graphic
    end
  end

  def cache_toc_graphic
    if related_identifier&.toc_url.present? && related_identifier.valid_toc_url?
      begin
        self.img = open(related_identifier.toc_url)
      rescue => exception
        
      end
    end
  end
  
  def cache_img_url
    if img.url == "/images/original/missing.png" && related_identifier.valid_toc_url?
      self.update_column(:img_url, self.related_identifier&.toc_url)
    elsif related_identifier.valid_toc_url?
      self.update_column(:img_url, self.img.url)
    else 
      self.update_column(:img_url, nil)
    end
  end

  def cache_size
    self.update_column(:size_count, interactions.active.count)
  end

  def update_dois
    if interactions.present?
      interactions.each do |interaction|
        unless interaction.related_identifier == related_identifier
          interaction.doi = related_identifier.relatedIdentifier if related_identifier.relatedIdentifierType == "DOI"
          interaction.interaction_related_identifiers.first.related_identifier = related_identifier
          interaction.save
        end
      end
    end
  end


  

  def meta_updater
    puts cyan __method__
    if related_identifier.crossref.present?
      puts green "REL present"
      unless description.present?
        puts green "Description absent"
        self.description = related_identifier.crossref["abstract"].gsub(/<("[^"]*"|'[^']*'|[^'">])*>/, '') if related_identifier.crossref["abstract"].present?
      end
      unless subject_list.present?
        puts green "Subjects absent"
        self.subject_list = related_identifier.crossref["subject"] if related_identifier.crossref["subject"].present?
      end
    end
  end

  def curation_status
    if dataset_interactions.present?
      if interactions.map{|i| (i.revision == "accepted" || i.revision == "published" ) ? true : false}.all?
        self.label = "curated"
      else
        self.label = "uncurated"
      end
    else
      self.label = ""
    end
  end

  def curated?
    if label == "curated"
      true
    else
      false
    end
    
  end

  def related_identifier
    self.dataset_related_identifiers.first.related_identifier
  end

  def related_identifier=(name)
    self.dataset_related_identifiers.first.related_identifier = name if name.present?
  end


  def related_identifiers_build
    num = (1 - self.dataset_related_identifiers.length)
    num.times{ self.dataset_related_identifiers.build }
    logger.fatal "inside model Dataset method related_identifiers_build, dataset_related_identifiers: #{dataset_related_identifiers}"
  end


  def auto_update_creators
    if related_identifier.crossref.present? && related_identifier.crossref["author"].present?
      authors=related_identifier.crossref["author"].each{|obj| obj.deep_symbolize_keys!}
      initialize_creator_references(authors)#works
    end
  end

  def initialize_revision
    puts cyan __method__
    target = ENV["ENVURL"] + "/datasets/#{id}"
    if related_identifier.relatedIdentifierType == 'DOI' && interactions.present? && state == 'registered'
      puts green "all requirements met DOI"
      interactions.each do |interaction|
          puts green "Interaction_ID: #{interaction.id}"
          if interaction.revision == "accepted"
            interaction.update(
              embargo: false,
              published: true,
              revision: 'published'
            )
          elsif interaction.revision == "created"
            interaction.update(
              embargo: false,
              published: false,
              revision: 'submitted',
              reviewer: User.find_by_email("contact@suprabank.org")
            )
          end
        end
    elsif related_identifier.relatedIdentifierType == 'URL' &&  related_identifier.relatedIdentifier == target && state == 'findable' && interactions.present?
      puts green "all requirements met mere Dataset"
      interactions.each do |interaction|
          if interaction.embargo?
            interaction.update(
              embargo: false,
              published: true,
              revision: "submitted"
            )
          elsif interaction.revision == "accepted"
            interaction.update(
              embargo: false,
              published: true,
              revision: "published"
            )
          else 
            interaction.update(
              embargo: false,
              published: true,
            )
          end
      end
    elsif related_identifier.relatedIdentifierType == 'DOI' && state == 'findable' && interactions.present?
      puts green "all requirements met DOI"
      interactions.each do |interaction|
          if interaction.embargo?
            interaction.update(
              embargo: false,
              published: true,
              revision: "submitted"
            )
          elsif interaction.revision == "accepted"
            interaction.update(
              embargo: false,
              published: true,
              revision: "published"
            )
          else 
            interaction.update(
              embargo: false,
              published: true,
            )
          end
      end
    end
  end

  def destroy_on_datacite
    update_entry(self, "Delete", "hide")
  end

  def sanitize_primary_reference
    self.primary_reference = Bibliographic.doi_extractor(primary_reference) if primary_reference.present?
  end

  def set_primary_identifier
    puts cyan __method__
    if primary_reference.present?
      identifier = RelatedIdentifier.where(relatedIdentifier: primary_reference).first_or_create(relatedIdentifier: primary_reference)
      relation_type = 3
    else
      target = ENV["ENVURL"] + "/datasets/#{id}"
      identifier = RelatedIdentifier.where(relatedIdentifier: target).first_or_create(relatedIdentifier: target, relatedIdentifierType: "URL", url: target)
      relation_type = 21
    end
    puts "identifier #{identifier.id}"
    dataset_related_identifiers.first.update(related_identifier: identifier, relationType: relation_type)
  end




  def assign_interactions
    puts cyan __method__
    if related_identifier.relatedIdentifierType == "DOI"
      interactions = related_identifier.interactions.active.where(user: users.first).includes(:datasets).where(datasets: {id: nil})
      self.interactions << interactions
      # interaction_ids = interactions_search&.ids.uniq
      # logger.debug "Assign Interactions interaction_ids: #{interaction_ids}"
      # #https://stackify.com/understanding-absence-in-ruby-present-blank-nil-empty/
      # #https://mitrev.net/ruby/2015/11/13/the-operator-in-ruby/
      # interaction_ids&.each{|interaction_id| self.dataset_interactions.build(:interaction_id => interaction_id)}
      # #interaction_ids&.each{|interaction_id| DatasetInteraction.create(:dataset_id => self.id, :interaction_id => interaction_id)}
    end
  end

  def unitize_dataset_creators

    DatasetCreator.sanitize_dataset_creators
    # all = dataset_creators
    # uniq_dcs = dataset_creators.select(:creator_id).distinct
    # unless all.count == uniq_dcs.count
    #   uniq_array = uniq_dcs.map(&:creator_id)
    #   all.destroy_all
    #   uniq_array.each {|dscid| dataset_creators.build(creator_id: dscid)}
    # end
  end

  def empty_dataset_creator
    puts cyan __method__
    empty_creators = creators.where(givenName: nil).or(creators.where(givenName: ""))
    empty_dataset_creators = dataset_creators.where(creator: empty_creators)
    empty_dataset_creators.destroy_all
  end
  
  def empty_dataset_contributor
    empty_contributors = contributors.where(givenName: nil).or(contributors.where(givenName: ""))
    empty_dataset_contributors = dataset_contributors.where(contributor: empty_contributors)
    empty_dataset_contributors.destroy_all
  end

  def primary_reference_approval

    if related_identifiers.first.relatedIdentifierType == "DOI"
      return interactions.map{|int| int.related_identifier == related_identifiers.first}.all?
    end
  end

  def audition

    summary = {valid: true, interactions: "present", creators: "present", primary_reference_approval: true, label: 'curated'}
    unless valid?
      summary[:valid] = false
    end
    unless interactions.present?
      summary[:interactions] = "missing"
    end
    unless creators.present?
      summary[:creators] = "missing"
    end
    unless primary_reference_approval
      summary[:primary_reference_approval] = false
    end
    unless label == 'curated'
      summary[:label] = label
    end
    return summary
  end

  def audit?

    if valid? && interactions.present? && creators.present? && primary_reference_approval
      return true
    else
      return false
    end
  end

  def check_reference_discrepancy?

    if dataset_interactions.present?
      dataset_interactions.any? {|dataset_interaction|
        dataset_interaction.reference_discrepancy?
      }
    end
  end

  def update_interaction_dois

    if dataset_interactions.present? && check_reference_discrepancy?
      dataset_interactions.each {|dataset_interaction|
          interaction = dataset_interaction.interaction
          unless interaction.published?
            interaction.update(doi: self.dataset_related_identifiers.first.related_identifier.relatedIdentifier)
          end
      }
    end
  end


  def valid_reference_doi?

    if dataset_related_identifiers.first.present? && dataset_related_identifiers.first.related_identifier.relatedIdentifier.present?
        dataset_related_identifiers.first.related_identifier.relatedIdentifier.gsub!(/https:\/\/doi.org\//,"")
        doi_safe=dataset_related_identifiers.first.related_identifier.relatedIdentifier.gsub(/[^0-9A-Za-z^\/.-]/){|char| "%"+char.ord.to_s(16)}
        begin
          hash = Serrano.registration_agency(ids: doi_safe)[0].deep_symbolize_keys
        rescue Serrano::NotFound  => e
          hash = "Recond not found"
        rescue StandardError  => e
          hash = "Some other error"
        end
    end
    return (hash.class == Hash)
  end


  include Rails.application.routes.url_helpers

  def mere_dataset
    if dataset_related_identifiers.first.related_identifier.blank?
      dsri = dataset_related_identifiers.first
      target = ENV["ENVURL"] + "/datasets/#{id}"
      self_identifier = RelatedIdentifier.where(relatedIdentifier: target).first_or_create({relatedIdentifier: target, relatedIdentifierType: "URL"})
      self_identifier.update(url: target)
      dsri.update({related_identifier_id: self_identifier.id, relationType: 21})
      #the method was checked, it is well performing from IRB
    end
  end

  def update_info
    mere_dataset
    if state == "draft"
      event = "hide"
    elsif state == "registered"
      if datacite.present?
        #maybe the saved state in datacite json can serve as conditional test
        if datacite["data"]["attributes"]["state"] == "draft" #causes problems in register task, no method error for nil class []
          self.update_column(:registered, Date.current)
          event = "register"
        elsif datacite["data"]["attributes"]["state"] == "findable"
          event = "hide"
        end
      else
        event = "register"
      end
    elsif state == "findable"
      event = "publish"
    end
    self.update_column(:datacite, update_entry(self, "Put", event))
    logger.debug "#{green "update info"} dataset id: #{id}"
    if state == "registered" || state == "findable"
      if datacite["data"].present?
        logger.debug "#{green "data is present"} dataset id: #{id}"
      elsif datacite["errors"].present?
        logger.debug "#{red "errors is present"}  dataset id: #{id}"
        errors.add("datacite", datacite["errors"][0]["title"])
      end
    end

    return datacite
  end

  def last_creator_standing
    unless self.dataset_creators.present?
      self.initialize_creator
      self.save
    end
  end
  

  def generate_publication_year

    if self.available_at.present?
      self.publicationYear = self.available_at.year
    elsif self.updated_at.present?
      self.publicationYear = self.updated_at.year
    elsif self.created_at.present?
      self.publicationYear = self.created_at.year
    else
      self.publicationYear = Date.current.year

    end
  end

  def generate_size
    if interactions.active.count == 1
      self.update_column(:size, "#{interactions.active.count} interaction")
    else
      self.update_column(:size, "#{interactions.active.count} interactions")
    end
  end


  def generate_preliminary_doi
    #prefix = "10.34804/" #production
    Dataset.last.present? ? last_id = Dataset.last.id : last_id = 0
    suffix = Date.current.strftime("%Y%m%d") + (last_id + 1).to_s
    self.identifier = ENV['PREFIX'] + ENV['INFIX'] + suffix
  end


  def generate_doi
    #prefix = "10.34804/" #production
    suffix = Date.current.strftime("%Y%m%d") + self.id.to_s
    self.identifier = ENV['PREFIX'] + ENV['INFIX'] + suffix
  end

  def initialize_creator
    puts cyan __method__
    record = Creator.user_assign_creator(users.first)
    self.dataset_creators.build(creator: record)
    #DatasetCreator.build({dataset_id: self.id, creator_id: record.id})
  end

  def initialize_creator_references(authors)
    puts cyan __method__
    if authors.present?
      dataset_creators.destroy_all
      authors.each {|author|
        #record = DatasetCreator.generate_creator_reference(author)
        self.dataset_creators.build.generate_creator_reference(author)
      }
    end
    #DatasetCreator.build({dataset_id: self.id, creator_id: record.id})
  end

  def initialize_contributor
    record = Contributor.user_assign_contributor(users.first)
    unless dataset_contributors.where(contributor: record).present?
      self.dataset_contributors.build(contributor: record, contributorType:4)
    end
    #DatasetCreator.build({dataset_id: self.id, creator_id: record.id})
  end

  def initialize_contributors
    users.each do |user| 
      record = Contributor.user_assign_contributor(user)
      unless dataset_contributors.where(contributor: record).present?
        self.dataset_contributors.build(contributor: record, contributorType:4)
      end
    end
    #DatasetCreator.build({dataset_id: self.id, creator_id: record.id})
  end

  def reference_doi(identifier)

    #identifier = parameters["0"][:relatedIdentifier]
    record = RelatedIdentifier.assign_identifier(identifier, "DOI")
    dataset_related_identifiers.first.update(:related_identifier => record, :relationType => 3)
    logger.debug "reference_doi: #{dataset_related_identifiers.first.attributes}"
  end


  def primary_reference_must_be_unique

    identifier = self.primary_reference
    if DatasetRelatedIdentifier.primary_reference_doi?(identifier)[:unique]
      errors.add("Primary Reference", "must be unique")
    end
  end




  def creators_update(params)
    puts cyan __method__
    if params.present?
      puts green "creators_update params: #{params} #{Time.now}"
      ids_a=params.map{|k,v| v[:creator_id]}
      puts cyan ids_a
      if ids_a.include?("")
        
        i=0
        dataset_creators.destroy_all
      params.each do |k,v|
        puts cyan "loop inside #{__method__}"
        logger.debug "i=#{i}, k=#{k}, v=#{v}"
        puts red "Destroy? #{v["_destroy"]}"
        logger.debug "i=#{i}, dataset_creators are present"
        if v["_destroy"] == "false"
          puts green "This dataset creator is supposed to be created"
          self.dataset_creators.build.creator_creation(v)
        else
          puts red "This dataset creator is supposed to be destroyed"
        end
        i += 1
      end
      self.save
    end
    end
  end

  def contributors_update(params)

    if params.present?

      logger.debug "contributors_update params: #{params}"
      i=0
      params.each do |k,v|
        logger.debug "i=#{i}, k=#{k}, v=#{v}"
        if self.dataset_contributors[i].present?
          logger.debug "i=#{i}, dataset_contributors are present"
          self.dataset_contributors[i].contributor_update(v)
        end
        i += 1
      end
    end
  end



  def self.citation_request(doi)
    if doi.present?
        #doi.gsub!(/https:\/\/doi.org\//,"")
				#doi_safe=doi.gsub(/[^0-9A-Za-z^\/.-]/){|char| "%"+char.ord.to_s(16)}
        doi_safe = URI.encode(doi.strip.gsub(/https:\/\/doi.org\//,""))
				begin
          hash = Serrano.registration_agency(ids: doi_safe)[0].deep_symbolize_keys
        rescue StandardError => e
          hash = {status: "bad"}
        end
        if hash[:status] == "ok"
          puts "will use Serrano"
          json = Serrano.content_negotiation(ids: doi_safe, format: "citeproc-json")
          puts json
          if json == "Resource not found."
            puts "will use direct crossref api"
            hash=Bibliographic.crossref_api(doi)
            if hash[:status] == "ok"
              csl_hash = hash[:message]
            end
          else
            csl_hash = json && json.length >= 2 ? JSON.parse(json) : nil
          end
          symbol_hash = csl_hash.deep_symbolize_keys
        else
          puts "will use direct crossref api"
          hash=Bibliographic.crossref_api(doi)
          if hash[:status] == "ok"
            csl_hash = hash[:message]
            symbol_hash = csl_hash.deep_symbolize_keys
          else
            symbol_hash = {title: nil, abstract: nil}
          end
        end
        return symbol_hash
        
    end
    
  end

  def interaction_scope

    interactions = Interaction.active.includes(:datasets).where(datasets: {id: nil})
    case self.users.first.user_role
    when "user"
      scope = interactions.where(user_id: self.users.first.id)
    when "admin"
      scope = interactions.all
    end
  end

  def addition_scope(user)

    interactions = Interaction.active.where(user_id: user.id).includes(:datasets).where(datasets: {id: nil}).where(doi: nil)
    return interactions
  end


  def interactions_search
    if self.dataset_related_identifiers.first.relatedIdentifier.present?
      interactions_scope = interaction_scope
      interactions = interactions_scope.where(doi: self.dataset_related_identifiers.first.relatedIdentifier)
    end
  end


  def assign_reference_interactions
    if self.related_identifiers.first.relatedIdentifierType == "DOI"
      interaction_ids = interactions_search&.ids.uniq
      logger.debug "Assign Interactions interaction_ids: #{interaction_ids}"
      #https://stackify.com/understanding-absence-in-ruby-present-blank-nil-empty/
      #https://mitrev.net/ruby/2015/11/13/the-operator-in-ruby/
      interaction_ids&.each{|interaction_id| self.dataset_interactions.build(:interaction_id => interaction_id)}
      #interaction_ids&.each{|interaction_id| DatasetInteraction.create(:dataset_id => self.id, :interaction_id => interaction_id)}
    end
  end


  def rights_update

    case self.rights
    when "Creative Commons Attribution Share Alike 4.0 International"
      self.rightsURI = "https://creativecommons.org/licenses/by-sa/4.0/legalcode"
      self.rightsIdentifier = "cc-by-sa-4.0"
    when "Creative Commons Attribution 4.0 International"
      self.rightsURI = "https://creativecommons.org/licenses/by/4.0/legalcode"
      self.rightsIdentifier = "cc-by-4.0"
    when "Creative Commons Zero v1.0 Universal"
      self.rightsURI = "https://creativecommons.org/publicdomain/zero/1.0/legalcode"
      self.rightsIdentifier = "cc0-1.0"
    end
  end


  def csv_export

    require 'csv'
    file = "#{Rails.root}/public/tmp/csv/#{self.id}.csv"
    csvinteractions = self.interactions
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
        "Host",
        "Host SMILES",
        "Indicator",
        "Indicator SMILES",
        "Cofactor",
        "Cofactor SMILES",
        "Bindign constant",
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
          s.id,
          s.assay_type,
          s.technique,
          s.molecule.display_name,
          s.molecule.iso_smiles,
          s.host.display_name,
          s.host.iso_smiles,
          s.indicator.present? ? s.indicator.display_name : nil,
          s.indicator.present? ? s.indicator.iso_smiles : nil,
          s.conjugate.present? ? s.conjugate.display_name : nil,
          s.conjugate.present? ? s.conjugate.iso_smiles : nil,
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

  def generate_alternateIdentifier

    #base_url = "https://suprabank.org" production
    #base_url = "http://suprabank-staging.int.kit.edu:3030" #staging
    if state == "registered" || state == "draft"
      if preview_token.blank?
        self.preview_token = SecureRandom.urlsafe_base64.to_s
        self.alternateIdentifier = ENV["ENVURL"] + "/datasets/#{preview_token}/preview"
      end
    else
        self.preview_token = nil
        self.alternateIdentifier = ENV["ENVURL"] + "/datasets/#{id}"
    end
    return alternateIdentifier
  end

  def ris_export
    url = bib_to_ris(self.bibtex.path, self.identifier)
    return url
  end

  def enw_export
    url = bib_to_enw(self.bibtex.path, self.identifier)
    return url
  end


end
