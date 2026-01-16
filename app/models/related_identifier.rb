class RelatedIdentifier < ActiveRecord::Base
  #modules
  include Bibliographic
  #paperclip
  has_attached_file :bibtex, validate_media_type: false
  do_not_validate_attachment_file_type :bibtex
  #associations
  has_many :dataset_related_identifiers
  has_many :datasets, :through => :dataset_related_identifiers
  has_many :interaction_related_identifiers
  has_many :interactions, :through => :interaction_related_identifiers
  #validations
  validates :relatedIdentifier, uniqueness: true
  #callbacks
  #after_initialize :compose_url
  before_save :citation_checker, :doi_validation
  before_save :add_crossref_on_change, :clip_bibtex_on_change, :meta_data_retriever_on_change
  before_create :meta_updater
  #scopes
  scope :deleted, -> { where.not(deleted_at: nil) }


  def citation_checker
    unless citation.present?
      if relatedIdentifier.present? && relatedIdentifierType == "DOI"
        meta_updater  
      end
    end
  end

  def meta_updater
    self.check_doi_validity
    self.compose_url
    self.add_crossref
    self.clip_bibtex
    self.meta_data_retriever
  end

  def meta_data_retriever_on_change
    if relatedIdentifier_changed?
      self.meta_updater
    end
  end

  def valid_toc_url?
    uri = URI.parse(toc_url) 
    uri.is_a?(URI::HTTP) && !uri.host.nil?
  rescue URI::InvalidURIError
    false
  end
  
  def compose_url
    if doi_validity
      self.url = URI.encode("https://doi.org/" + self.relatedIdentifier.to_s)
    end
  end

  def self.assign_identifier(identifier, identifierType)
    if identifier.present? && identifierType == "DOI"
      doi = Bibliographic.doi_extractor(identifier)
    else
      doi = nil
    end
    record = RelatedIdentifier.where(relatedIdentifier: doi).first_or_create({relatedIdentifier: doi, relatedIdentifierType: identifierType})
    return record
  end


  def check_doi_validity
    if relatedIdentifier.present? && relatedIdentifierType == "DOI"
      self.doi_validity = valid_reference_doi?(relatedIdentifier)
    end
  end


  def doi_validation
    if relatedIdentifier_changed?
      self.check_doi_validity
    end
  end

  def clip_bibtex
    if doi_validity
      begin
      Timeout::timeout(20) do
        bib_file_path = doi_bibtex(self.relatedIdentifier)
        logger.debug bib_file_path
        if bib_file_path.present?
          bib_file = File.open(bib_file_path)
          self.bibtex = bib_file
        end
      end #20 sec timeout
      rescue StandardError => e
        self.bibtex = nil
      end #exception handling
    end #doi validation
  end


	def clip_bibtex_on_change
		if relatedIdentifier.present? && relatedIdentifier_changed?
			begin
			Timeout::timeout(5) {self.clip_bibtex}
			rescue StandardError => e
				self.bibtex = nil
			end
		end
	end

  def add_crossref
    if doi_validity
      begin
        Timeout::timeout(20) do
          csl_hash = doi_request(relatedIdentifier)
          if csl_hash.present?
            self.citation = citation_renderer(csl_hash)
            self.crossref = csl_hash
          else
            self.citation = "Resource not found. Please verify DOI with CrossRef."
          end
        end #20 sec timeout
      rescue StandardError => e
        self.citation = nil
      end #exception handling
    end
  end

  def add_crossref_on_change
    if relatedIdentifier.present? && relatedIdentifier_changed?
      begin
        Timeout::timeout(5) {self.add_crossref}
      rescue StandardError => e
        self.bibtex = nil
      end
    end
  end




  def bibtex_export
    url = doi_bibtex(self.relatedIdentifier)
    return url
  end

  def ris_export
    url = bib_to_ris(self.bibtex.path, self.relatedIdentifier)
    return url
  end

  def enw_export
    url = bib_to_enw(self.bibtex.path, self.relatedIdentifier)
    return url
  end

  def citation_pdf
    if self.crossref.present?
      pdf_link self.crossref
    else
      nil
    end
  end


end
