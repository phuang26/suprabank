class Contributor < ActiveRecord::Base
  include Orcid
  has_many :dataset_contributors
  has_many :datasets, :through => :dataset_contributors
  before_save :full_name, :set_nameType



  def full_name
    self.contributorName = self.givenName.to_s + " " + self.familyName.to_s
  end

  def set_nameType
    self.nameType = "Personal"
  end



  def self.user_contributor(user)
    if user.nameIdentifier.present?
      begin
        search = Contributor.find(nameIdentifier: user.nameIdentifier)
      rescue ActiveRecord::RecordNotFound
        search = Contributor.where('"givenName" = ? AND "familyName" = ?',"#{user.givenName}","#{user.familyName}").first
      end
    else
      search = Contributor.where('"givenName" = ? AND "familyName" = ?',"#{user.givenName}","#{user.familyName}").first
    end
    return search

  end


  def self.user_assign_contributor(user)
    search = self.user_contributor(user)
    if search.present?
      record = search
    else
      record = Contributor.create({givenName: user.givenName, familyName:user.familyName, nameIdentifier:user.nameIdentifier, affiliation:user.affiliation, affiliationIdentifier:user.affiliationIdentifier})
    end
    return record
  end


end
