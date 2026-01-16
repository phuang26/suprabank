class DatasetContributor < ActiveRecord::Base
  belongs_to :dataset
  belongs_to :contributor
  attr_accessor :contributor_givenName, :contributor_familyName, :contributor_nameIdentifier, :contributor_affiliationIdentifier, :contributor_affiliation

    enum contributorType: {
      ContactPerson: 1,
      DataCollector: 2,
      DataCurator: 3,
      DataManager: 4,
      Distributor: 5,
      Editor: 6,
      HostingInstitution: 7,
      Producer: 8,
      ProjectLeader: 9,
      ProjectManager: 10,
      ProjectMember: 11,
      RegistrationAgency: 12,
      RegistrationAuthority: 13,
      RelatedPerson: 14,
      Researcher: 15,
      ResearchGroup: 16,
      RightsHolder: 17,
      Sponsor: 18,
      Supervisor: 19,
      WorkPackageLeader: 20,
      Other:  21
    }

  #getter
    def contributor_givenName
      self.contributor.try(:givenName)
    end

    def contributor_familyName
      self.contributor.try(:familyName)
    end

    def contributor_nameIdentifier
      self.contributor.try(:nameIdentifier)
    end

    def contributor_affiliationIdentifier
      self.contributor.try(:affiliationIdentifier)
    end

    def contributor_affiliation
      self.contributor.try(:affiliation)
    end




    def contributor_update(parameters)
      #something
      logger.debug "contributor_update Params: #{parameters}"
      logger.debug self.id
      unless parameters[:id].present?
        parameters[:id] = self.id
      end

      if parameters.present?
          self.generate_contributor(parameters)
      end
      self.save
    end




    def contributor_checkup(parameters)
      if parameters[:contributor_nameIdentifier].present?
        search = Contributor.where('"nameIdentifier" = ?',parameters[:contributor_nameIdentifier])
      else
        search = Contributor.where('"givenName" = ? AND "familyName" = ?',parameters[:contributor_givenName],parameters[:contributor_familyName])
      end
      return search
    end


    def generate_contributor(parameters)
      search = contributor_checkup(parameters)

      if search.empty?
        self.contributor = Contributor.create({givenName: parameters[:contributor_givenName], familyName: parameters[:contributor_familyName], nameIdentifier: parameters[:contributor_nameIdentifier], affiliationIdentifier: parameters[:contributor_affiliationIdentifier], affiliation: parameters[:contributor_affiliation]})
      else
        self.contributor = search.first
      end

    end



    def contributor_access
        search = Contributor.where('"givenName" = ? AND "familyName" = ?',"#{self.contributor_givenName}","#{self.contributor_familyName}")
        if search.empty?
          self.contributor = Contributor.create({givenName: self.contributor_givenName, familyName: self.contributor_familyName})
        else
          self.contributor = search.first
        end
    end

end
