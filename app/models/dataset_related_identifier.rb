class DatasetRelatedIdentifier < ActiveRecord::Base
  #modules
  include Bibliographic
  #associations
  belongs_to :dataset
  belongs_to :related_identifier
  #validates :related_identifier_id, uniqueness: true if: :primary_rank?

  enum relationType: {
    IsCitedBy: 1,
    Cites: 2,
    IsSupplementTo: 3,
    IsSupplementedBy: 4,
    IsContinuedBy: 5,
    Continues: 6,
    IsDescribedBy: 7,
    Describes: 8,
    HasMetadata: 9,
    IsMetadataFor: 10,
    HasVersion: 11,
    IsVersionOf: 12,
    IsNewVersionOf: 13,
    IsPreviousVersionOf: 14,
    IsPartOf: 15,
    HasPart: 16,
    IsReferencedBy: 17,
    References: 18,
    IsDocumentedBy: 19,
    Documents: 20,
    IsCompiledBy: 21,
    Compiles: 22,
    IsVariantFormOf: 23,
    IsOriginalFormOf: 24,
    IsIdenticalTo: 25,
    IsReviewedBy: 26,
    Reviews: 27,
    IsDerivedFrom: 28,
    IsSourceOf: 29,
    IsRequiredBy: 30,
    Requires: 31,
    IsObsoletedBy: 32,
    Obsoletes: 33,
  }


  attr_accessor :relatedIdentifier, :relatedIdentifierType

  def primary_rank?
    self.rank == 1
  end

  def self.primary_reference_doi?(identifier)
    if identifier.present?
      doi = Bibliographic.doi_extractor(identifier)
    else
      doi = "placeholder DOI"
    end
    dataset = Dataset.where(primary_reference: doi)
    #dsi = DatasetRelatedIdentifier.where(:rank => 1).includes(:related_identifier).where(related_identifiers: {relatedIdentifier:doi})
    hash = {
      unique: dataset.present?,
      dataset_id: (dataset.first.id  if dataset.present? )
    }
    return hash

  end

  #getter
    def relatedIdentifier
      self.related_identifier.try(:relatedIdentifier)
    end



    def relatedIdentifierType
      self.related_identifier.try(:relatedIdentifierType)
    end


    def relatedIdentifier_update(parameters)
      #something
      logger.debug "Params: #{parameters}"
      logger.debug self.id

      unless parameters[:id].present?
        parameters[:id] = self.id
      end

      if parameters.present?
        if self.related_identifier.present?
          self.relatedIdentifier.update({relatedIdentifier: parameters[:relatedIdentifier], relatedIdentifierType: parameters[:relatedIdentifierType]})
        else
          if parameters[:relatedIdentifier_id].present?
            self.relatedIdentifier = relatedIdentifier_id
          else
            self.generate_relatedIdentifier(parameters)
          end
        end
        self.save

      end

    end

    def relatedIdentifier_checkup(parameters)
      if parameters[:relatedIdentifier].present?
        search = RelatedIdentifier.find_by_relatedIdentifier(parameters[:relatedIdentifier])
      else
        search = nil
      end
      return search
    end


    def generate_relatedIdentifier(parameters)
      search = relatedIdentifier_checkup(parameters)

      if search.empty?
        self.relatedIdentifier = RelatedIdentifier.create({relatedIdentifier: parameters[:relatedIdentifier], relatedIdentifierType: parameters[:relatedIdentifierType]})
      else
        self.relatedIdentifier = search.first
      end

    end


end
