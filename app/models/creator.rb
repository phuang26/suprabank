class Creator < ActiveRecord::Base
  include Orcid
  has_many :dataset_creators
  has_many :datasets, :through => :dataset_creators
  before_save :full_name, :set_nameType
  after_initialize :full_name, :set_nameType, :set_name #slows down the app, recaftor!

  def self.find_duplicates
    #Creator.select(:creatorName).group(:creatorName).having('count(*) > 1').size
    orcid_array = Creator.select(:nameIdentifier).group(:nameIdentifier).having('count(*) > 1').size.map{|k,v| k}.compact
  end

  def self.remove_vaccancy_duplicates
    id_hash = Creator.where(nameIdentifier: Creator.find_duplicates).map{|k| [k.id, k.datasets.count]}.to_h
    vaccancy_array = id_hash.map{|k,v| v==0 ? k : nil}.compact
    Creator.where(id: vaccancy_array).destroy_all
  end

  def self.remove_from_identical_dataset(creator_id_hash)
    major_creator_id = creator_id_hash.sort_by{|k,v| v}.reverse[0][0]
    dataset_ids = Creator.where(id: major_creator_id).map{|k| k.dataset_ids }
    h = creator_id_hash.clone
    h.delete(major_creator_id)
    ho=DatasetCreator.where(creator_id: h.map{|k,v| k}, dataset_id: dataset_ids[0])
    ho.destroy_all
  end

  def self.unify_duplicates
    Creator.remove_vaccancy_duplicates
    #id_hash = Creator.where(nameIdentifier: Creator.find_duplicates.first).map{|k| [k.id, k.datasets.ids]}.to_h
    Creator.find_duplicates.each {|orcid|
      id_hash = Creator.where(nameIdentifier: orcid).map{|k| [k.id, k.datasets.count]}.to_h
      Creator.remove_from_identical_dataset(id_hash)
    }

  end

  def full_name
    self.creatorName = self.givenName.to_s + " " + self.familyName.to_s
  end

  def set_name
    self.name = "#{self.familyName}, #{self.givenName}"
  end


  def set_nameType
    self.nameType ||= "Personal"
  end



  def self.user_creator(user)
    if user.nameIdentifier.present?
      begin
        search = Creator.find(nameIdentifier: user.nameIdentifier)
      rescue ActiveRecord::RecordNotFound
        search = Creator.where('"givenName" = ? AND "familyName" = ?',"#{user.givenName}","#{user.familyName}").first
      end
    else
      search = Creator.where('"givenName" = ? AND "familyName" = ?',"#{user.givenName}","#{user.familyName}").first
    end
    return search

  end


  def self.user_assign_creator(user)
    search = self.user_creator(user)
    if search.present?
      record = search
    else
      record = Creator.create({givenName: user.givenName, familyName:user.familyName, nameIdentifier:user.nameIdentifier, affiliation:user.affiliation, affiliationIdentifier:user.affiliationIdentifier})
    end
    return record
  end

end

#excerpt of schema
=begin
create_table "creators", force: :cascade do |t|
  t.text     "creatorName"
  t.text     "nameType"
  t.text     "givenName"
  t.text     "familyName"
  t.text     "nameIdentifier"
  t.text     "nameIdentifierScheme",        default: "ORCID"
  t.text     "schemeURI",                   default: "https://orcid.org"
  t.text     "affiliation"
  t.text     "affiliationIdentifier"
  t.text     "affiliationIdentifierScheme", default: "ROR"
  t.text     "SchemeURI",                   default: "https://ror.org/"
  t.datetime "created_at",                                                null: false
  t.datetime "updated_at",                                                null: false
end
=end
