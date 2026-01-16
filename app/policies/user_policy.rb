class UserPolicy < ApplicationPolicy

  def group_presence?
    record.groups.present? && record.assignments.first.confirmed
  end


  def group_admin_rights?
    if group_presence?
      if user.groups.present?
        if user.groups.first == record.groups.first
          user.group_admin?
        end
      end
    end
  end

  def group_member?
    if group_presence?
      if user.groups.present?
         user.groups.first == record.groups.first
      end
    end
  end

  def reviewer?
    User.reviewers.include? record
  end

  def show?
      user.admin? || record == user || group_admin_rights? || group_member?
  end

  def admin_tasks
    record.admin?
  end

  def revisions?
    record == user && reviewer?
  end

  def editor_or_admin?
    if user.present? 
      user.admin? || user.editor?
    end
  end
  


    

end
