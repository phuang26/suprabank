class Assignment < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  belongs_to :desired_group, :class_name => 'Group'
  accepts_nested_attributes_for :group, :allow_destroy => true
  before_save :refine_url
  before_save :independence
  after_save :group_confirmation!
  after_update :reset_user_role


  def status
    published_interactions = group.present? ? group.group_interactions.published.where('created_at >?', 1.year.ago).count : user.interactions.published.where('created_at >?', 1.year.ago).count
    case published_interactions
    when 0..9
      status = "Cuprum"
      next_level = 10
    when 10..49
      status = "Argentum"
      next_level = 50
    else
      status = "Aurum"
      next_level = published_interactions
    end
    percentage = 100 * (published_interactions.to_f/next_level.to_f)
    return {count: published_interactions, status: status, next_level: next_level, percentage: percentage}
  end


  def reset_user_role
    if self.group_id_changed?
      self.user.user!
    end
  end

    def group_name
      self.group.try(:name)
    end

    def group_name=(name)
      if name.present?
        group = Group.find_by(name: name)
        if group.present?
          self.group = group
        else
          unless self.group.present?

            self.group = Group.new
          end
          self.group.name = name
        end
       end
    end

    def refine_url
      if self.group.present?
        if self.group.website.present?
          result = self.group.website =~ URI::regexp
          unless result.present?
            self.group.website = "http://"+self.group.website
          end
        end
      end
    end

    def independence
      if self.role == "independent"
        self.group = nil
        self.confirmed = true
        self.confirmed_at = Time.now.utc
      end
    end


    def group_confirmation!
      if (desired_role == "Group Member" || desired_role == "Group Leader")
        self.update_column(:confirmation_token, SecureRandom.urlsafe_base64.to_s)
        self.update_column(:confirmed, false)
        self.update_column(:confirmed_at, nil)
        AssignmentMailer.group_assignment_request(self).deliver!
      elsif desired_role == "independent"
        self.update_column(:group_id, nil)
        self.update_column(:role, desired_role)
        self.update_column(:desired_role, nil)
        self.update_column(:confirmed, true)
        self.update_column(:confirmed_at, Time.now.utc)
      end
    end

    def activate_group
      self.group_id = desired_group.present? ? desired_group.id : nil
      self.confirmation_token = nil
      self.confirmed = true
      self.confirmed_at = Time.now.utc
      self.role = desired_role
      self.desired_role = nil
      self.desired_group = nil
      self.save
    end

    def rollback_group
      self.confirmation_token = nil
      self.confirmed = true
      self.confirmed_at = Time.now.utc
      self.desired_role = nil
      self.desired_group = nil
      self.save
    end

def group_confirmation_token
    self.confirmation_token = SecureRandom.urlsafe_base64.to_s
end



end
