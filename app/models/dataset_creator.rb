class DatasetCreator < ActiveRecord::Base
  include Colors
  belongs_to :dataset
  belongs_to :creator
  attr_accessor :creator_givenName, :creator_familyName, :creator_nameIdentifier, :creator_affiliationIdentifier, :creator_affiliation #both
  #validates :creator, uniqueness: true
#setters are in a wider context the attr_accessor attributes mentioned above

#getter
include Ror
include Orcid
  def creator_givenName
    self.creator.try(:givenName)
  end

  def creator_familyName
    self.creator.try(:familyName)
  end

  def creator_nameIdentifier
    self.creator.try(:nameIdentifier)
  end

  def creator_affiliationIdentifier
    self.creator.try(:affiliationIdentifier)
  end

  def creator_affiliation
    self.creator.try(:affiliation)
  end


  def self.find_duplicates
    DatasetCreator.select(:creator_id, :dataset_id).group(:creator_id, :dataset_id).having('count(*) > 1').size.map{|k,v| [k.first, k.second]}.compact
  end

  def self.sanitize_dataset_creators
    DatasetCreator.find_duplicates.each{|i| DatasetCreator.sanitize_dataset(i.first, i.second)}
  end


  def self.sanitize_dataset(creator_id, dataset_id)
    result = DatasetCreator.where(creator_id: creator_id, dataset_id: dataset_id).order("created_at desc")
    result.limit(result.count - 1).destroy_all
  end


  def creator_update(parameters)
    #something
    logger.debug "creator_update Params: #{parameters}"
    logger.debug self.id
    unless parameters[:id].present?
      parameters[:id] = self.id
    end

    if parameters.present?
        self.generate_creator(parameters)
    end
    self.save
  end

  def creator_checkup(parameters)
    if parameters[:creator_nameIdentifier].present?
      begin
        search = Creator.where('"nameIdentifier" = ?',parameters[:creator_nameIdentifier])
          rescue ActiveRecord::RecordNotFound
        search = Contributor.where('"givenName" = ? AND "familyName" = ?',"#{user.givenName}","#{user.familyName}").first
      end
    else
      search = Creator.where('"givenName" = ? AND "familyName" = ?',parameters[:creator_givenName],parameters[:creator_familyName])
    end
    return search
  end


  def generate_creator(parameters)
    search = creator_checkup(parameters)
    self.creator = search.first_or_create({givenName: parameters[:creator_givenName], familyName: parameters[:creator_familyName], nameIdentifier: parameters[:creator_nameIdentifier], affiliationIdentifier: parameters[:creator_affiliationIdentifier], affiliation: parameters[:creator_affiliation]})
  end



  def creator_access
      search = Creator.where('"givenName" = ? AND "familyName" = ?',"#{self.creator_givenName}","#{self.creator_familyName}")
      if search.empty?
        self.creator = Creator.create({givenName: self.creator_givenName, familyName: self.creator_familyName})
      else
        self.creator = search.first
      end
  end


  def creator_reference_checkup(author)
    if author[:ORCID].present?
      orcid = author[:ORCID].gsub(/http:\/\/orcid.org\//,"")
      orcid = orcid.gsub(/https:\/\/orcid.org\//,"")
      search = Creator.where('"nameIdentifier" = ?',orcid)
    else
      search = Creator.where('"givenName" = ? AND "familyName" = ?',author[:given],author[:family])
    end
    return search
  end


  def generate_creator_reference(author)
    search = creator_reference_checkup(author)
    puts cyan __method__
    puts green author
    if search.empty?
      if author[:affiliation].present?
        author_affiliation = query_ror_by_affiliation(author[:affiliation])
      else
        author_affiliation = ["",""]
      end
      if author[:ORCID].present?
        orcid = author[:ORCID].gsub(/http:\/\/orcid.org\//,"")
        orcid = orcid.gsub(/https:\/\/orcid.org\//,"")
        orcid_hash = get_name_hash_from_id(orcid)
        self.creator = Creator.create({givenName: orcid_hash[:given_names], familyName: orcid_hash[:family_name], nameIdentifier: orcid, affiliationIdentifier: author_affiliation.second, affiliation: author_affiliation.first})
      else
        self.creator = Creator.create({givenName: author[:given], familyName: author[:family], affiliationIdentifier: author_affiliation.second, affiliation: author_affiliation.first})
      end
    else
      self.creator = search.first
    end
  end

  def creator_creation(creator)
    if creator.present?
      if creator[:creator_id].present?
        self.creator = Creator.find(creator[:creator_id])
      else
        self.creator = generate_creator(creator)
      end
      
    end
  end
  

end
