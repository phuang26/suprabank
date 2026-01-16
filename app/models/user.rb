class User < ActiveRecord::Base
  include Orcid
  enum user_role: {user: 0, group_admin: 1, admin: 2, editor: 3}

  after_initialize :set_default_role, :if => :new_record?
  after_initialize :set_default_group_role, :if => :new_record?


scope :users, -> { where(user_role: 0)}
scope :group_admins, -> { where(user_role: 1) }
scope :admins, -> { where(user_role: 2) }
scope :editors, -> { where(user_role: 3) }




  scope :reviewers, -> { where(email: ::ReviewerSet.to_a) }


  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
 has_attached_file :avatar, styles: { medium: "250x250>", thumb: "60x60>" }, default_url: "/images/:style/blank-user-profile.png"
 validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/
 validates :email, 'valid_email_2/email': { mx: true, disposable_with_whitelist: true, disallow_subaddressing: true, blacklist: true, message: "is not a valid email"}

 has_many :buffers
 has_many :interactions
 has_many :assignments, dependent: :delete_all
 has_many :groups, through: :assignments
 has_many :dataset_users
 has_many :datasets, :through => :dataset_users
 accepts_nested_attributes_for :assignments, :allow_destroy => true
 accepts_nested_attributes_for :groups, :allow_destroy => true
 #validate :one_group_leader
 before_save :refine_url
 validate :givenName_validity, :familyName_validity
 before_save :update_assignment

 before_save :sync_cooperators

 def update_assignment
   assignment = Assignment.find_by_user_id(id)
 end

 def givenName_validity
   if givenName.present?
     if URI.extract(givenName).present?
       errors.add(:givenName, "Please provide a valid given name, URLs are not allowed!")
     end
   end
 end

 def familyName_validity
   if familyName.present?
     if URI.extract(familyName).present?
       errors.add(:familyName, "Please provide a valid family name, URLs are not allowed!")
     end
   end
 end

 def set_default_role
   self.user_role ||= :user
 end

 def set_default_group_role
   self.role ||= "independent"
 end

 def self.find_creator(user)
   if user.nameIdentifier.present?
     begin
       search = Creator.where(nameIdentifier: user.nameIdentifier)
     rescue ActiveRecord::RecordNotFound
       search = Creator.where('"givenName" = ? AND "familyName" = ?',"#{user.givenName}","#{user.familyName}")
     end
   else
     search = Creator.where('"givenName" = ? AND "familyName" = ?',"#{user.givenName}","#{user.familyName}")
   end
   return search
 end

 def update_creator
   search = User.find_creator(self)
   if search.present?
     search.first.update({givenName: self.givenName, familyName:self.familyName, nameIdentifier:self.nameIdentifier, affiliation:self.affiliation, affiliationIdentifier:self.affiliationIdentifier})
   else
     Creator.create({givenName: self.givenName, familyName:self.familyName, nameIdentifier:self.nameIdentifier, affiliation:self.affiliation, affiliationIdentifier:self.affiliationIdentifier})
   end
 end

 def self.find_contributor(user)
   if user.nameIdentifier.present?
     begin
       search = Contributor.where(nameIdentifier: user.nameIdentifier)
     rescue ActiveRecord::RecordNotFound
       search = Contributor.where('"givenName" = ? AND "familyName" = ?',"#{user.givenName}","#{user.familyName}")
     end
   else
     search = Contributor.where('"givenName" = ? AND "familyName" = ?',"#{user.givenName}","#{user.familyName}")
   end
   logger.debug "Here comes the log from searching a user like contributor:#{search}"
   return search
 end

 def update_contributor
   search = User.find_contributor(self)
   if search.present?
     search.first.update({givenName: self.givenName, familyName:self.familyName, nameIdentifier:self.nameIdentifier, affiliation:self.affiliation, affiliationIdentifier:self.affiliationIdentifier})
   else
     Contributor.create({givenName: self.givenName, familyName:self.familyName, nameIdentifier:self.nameIdentifier, affiliation:self.affiliation, affiliationIdentifier:self.affiliationIdentifier})
   end
 end


  def sync_cooperators
    self.update_creator
    self.update_contributor
  end


 def listed_reviewer?
    if User.reviewers.include? self
      return true
    else
      false
    end
 end

  def full_name
    return "#{givenName} #{familyName}".strip if (givenName||familyName)
    'Anonymous'
  end

  def setup_assignments
    self.assignments.build
  end

def desired_group_name
  unless self.assignments.first.present?
    self.assignments << Assignment.new
  end
    self.assignments.first.desired_group.try(:name)
end

 def group_name
  unless self.assignments.first.present?
    self.assignments << Assignment.new
  end
   self.assignments.first.group.try(:name)
 end

 def group_name=(name)
   unless self.assignments.first.present?
     self.assignments << Assignment.new
   end
   if name.present?
     group = Group.find_by(name: name)
     if group.present?
       self.assignments.first.group = group
     else
       unless self.assignments.first.group.present?

         self.assignments.first.group = Group.new
       end
       self.assignments.first.group.name = name
     end
   end
 end

 def desired_group_name=(name)

   if self.assignments.first.present?
     assignment =  self.assignments.first
   else
     assignment =  Assignment.new
   end

   if Group.find_by(name: name).present?
     desiredGroup = Group.find_by(name: name)
   else
     desiredGroup = Group.create(name: name)
   end

   assignment.update(desired_group: desiredGroup)

 end

def role
  self.assignments.first.try(:role)
end

def desired_role
  self.assignments.first.try(:desired_role)
end

def role=(name)
  unless self.assignments.first.present?
    self.assignments << Assignment.new
  end
  self.assignments.first.role = name if name.present?
end

def desired_role=(name)
  if self.assignments.first.present?
    assignment =  self.assignments.first
  else
    assignment =  Assignment.new
  end
  assignment.update(desired_role: name)
end


def refine_url
  if self.url.present?
    result = self.url =~ URI::regexp
    unless result.present?
      self.url = "http://"+self.url
    end
  end
end

#custom validations

# def one_group_leader
#     if self.assignments.first.group.users.where(role: "Group Leader").size >= 1
#       errors.add(:role, "There can only be one group leader per group")
#     end
# end
end
