class DatasetInteraction < ActiveRecord::Base
  #validates_uniqueness_of :interaction_id, :scope => [:dataset_id]
  include Colors
  belongs_to :dataset
  belongs_to :interaction
  #attr_accessor :reference_discrepancy
  #after_initialize :reference_discrepancy?
  #after_save :add_interaction_identifier_association
  #after_create :add_interaction_identifier_association
  after_save :cache_size, :check_revision
  before_destroy  :remove_interaction_identifier_association

  def cache_size
    dataset.update_column(:size_count, dataset.interactions.active.count)
  end




  def reference_discrepancy?
    if dataset&.dataset_related_identifiers&.first&.related_identifier && dataset&.dataset_related_identifiers&.first&.related_identifier&.relatedIdentifierType == "DOI"
      if dataset&.dataset_related_identifiers&.first&.related_identifier&.relatedIdentifier&.presence == interaction&.doi&.presence
        return false
      else
        return true
      end
    else
      return false
    end

  end



  def remove_interaction_identifier_association
    puts cyan __method__
    interaction.doi = nil
    interaction.set_identifier
    puts cyan "#{interaction.doi}, #{interaction.id}"
    interaction.revision = "created"
    interaction.published = false
    interaction.embargo = true
    interaction.save
  end

  def add_interaction_identifier_association
    puts cyan __method__
    identifier = dataset.related_identifier.relatedIdentifier
    interaction.update(:doi => identifier)
    interaction.set_identifier
    interaction.save
    puts cyan "#{interaction.doi}, #{interaction.id}"
  end


  def check_revision
    dataset.initialize_revision
  end
  
end
