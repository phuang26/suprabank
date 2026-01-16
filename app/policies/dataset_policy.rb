class DatasetPolicy  < ApplicationPolicy

  def groupcheck? #must be recoded!!!
    if user.present?
      if user.groups.present?
        if record.user.groups.present?
          user.groups.first == record.user.groups.first
        end
      end
    end
  end

  def groupadmincheck?
    if user.present?
      if user.groups.present?
        if record.user.groups.present?
          if user.groups.first == record.user.groups.first
            user.group_admin?
          end
        else
          false
        end
      else
        false
      end
    end
  end

  def csv_exportable?
    if user.present?
      if record.state == "findable"
        record.users.exists?(user) || user.admin?
      else
        record.users.exists?(user)
      end
    end
  end
  

  def admin_groupadmin_editor?
    if user.present?
        user.admin? || groupadmincheck? || user.editor?
    end
  end

  def displayable?
    if user.present?
      record.state == "findable" || user.in?(record.users) || user.admin? 
    else
      record.state == "findable"
    end
  end


  def update?
    if user.present?
      unless record.state == 'findable'
        record.users.exists?(user) || user.editor? 
      else
        user.admin?
      end
    end
  end

  def destroy?
    if user.present?
      user.admin?  || record.users.exists?(user)
    end
  end

  def admin?
    if user.present?
      user.admin?
    end
  end


  def findable?
    if user.present?
      record.state == "findable" || user.admin?
    end
  end

  def user_edit?
    if user.present?
      record.users.exists?(user) && record.state != "findable"
    end
  end
  
  def rescue?
    if user.present?
      record.state == "findable" && user.admin?
    end
  end
  

  def published?
    record.state != "findable" || user.admin?
  end

  def editable?
    if user.present?
      record.state != "findable" && user.in?(record.users)
    end
  end

  class Scope < Scope
    def resolve
      if user.present?
        if user.admin?
          scope.all
        else
          scope.where(state: "findable")
        end
      else
        scope.where(state: "findable")
      end
    end
  end

  def self_revision?
    current_date_time = DateTime.parse(Time.now.to_s)
    start = DateTime.parse(ENV['REVSTART']) 
    ende = DateTime.parse(ENV['REVEND']) 
    if current_date_time.between?(start, ende)
      if user.present?
        user.in?(record.users) && record.state == "registered" && user.groups&.first&.id == 2 && record.interactions.map(&:revision).uniq.include?("submitted") && (record.interactions.map(&:revision).uniq.length == 1)
      end
    end
  end


  def self_revision_publish?
    current_date_time = DateTime.parse(Time.now.to_s)
    start = DateTime.parse(ENV['REVSTART']) 
    ende = DateTime.parse(ENV['REVEND']) 
    if current_date_time.between?(start, ende)
      if user.present?
        user.in?(record.users) && record.state == "registered" && user.groups&.first&.id == 2 && record.interactions.map(&:revision).uniq.include?("accepted") && (record.interactions.map(&:revision).uniq.length == 1)
      end
    end
  end

  def self_revision_interaction?
    current_date_time = DateTime.parse(Time.now.to_s)
    start = DateTime.parse(ENV['REVSTART']) 
    ende = DateTime.parse(ENV['REVEND']) 
    if current_date_time.between?(start, ende)
      if user.present?
        user.in?(record.users) && record.state == "registered" && user.groups&.first&.id == 2
      end
    end
    
  end
  

end
