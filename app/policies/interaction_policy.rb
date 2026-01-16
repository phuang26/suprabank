class InteractionPolicy  < ApplicationPolicy

  def groupcheck?
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

  def admin_groupadmin_editor?
    if user.present?
        user.admin? || groupadmincheck? || user.editor?
    end
  end

  def displayable?
    if record.embargo?
      (record.user == user if user.present?)
    else
      record.published? || admin_groupadmin_editor? || groupcheck? || (record.user == user if user.present?) || record.valid_reviewer?(user)
    end
  end


  def destroy?
    if user_presence
      if user.admin? 
        true
      elsif user==record.user && record.revision=="created" 
        true
      end
    end
  end

  def admin?
    if user.present?
      user.admin?
    end
  end

  def update?
    if user.present?
      user.admin?  || user==record.user || user.editor? || groupcheck || record.valid_reviewer?(user)
    end
  end

  def reviewer_view?
    if user.present?
      unless record.embargo
        if record.revision == "pending" || record.revision == "accepted"
          record.reviewer == user
        end
      end
    end
  end

  def revision_submitted?
    if user.present?
      unless record.embargo
        if record.revision == "submitted"
          record.reviewer == user
        end
      end
    end
  end

  def revision_pending?
    if user.present?
      unless record.embargo
        if record.revision == "pending"
          record.reviewer == user || user.admin? || groupadmincheck? || record.user == user
        end
      end
    end
  end

  def revision_accepted?
    if user.present?
      unless record.embargo
        if record.revision == "accepted"
          record.user == user || user.admin
        end
      end
    end
  end

  def revision_published?
    if user.present?
      unless record.embargo?
        if record.published?
          user.admin?
        else
          record.user == user || user.admin? || groupadmincheck?
        end
      else
        record.user == user
      end
    end
  end

  def revision_embargoed?
    if user.present?
      if record.embargo?
        record.user == user
      elsif record.embargo == false
        record.user == user || admin_groupadmin_editor? || groupcheck? || record.published? || record.valid_reviewer?(user)
      end
    else
      record.published?
    end
  end

  def show_buttons?
    if user.present?
      if record.embargo?
        record.user == user
      elsif record.published?
        if !record.dataset.curated?
          true
        else
          false
        end
      else
        groupadmincheck? || record.user == user
      end
    end
  end


  class Scope < Scope
    def resolve
      if user.present?
        if user.admin?
          scope.all
        else
          scope.where(published: true)
        end
      else
        scope.where(published: true)
      end
    end
  end

  class Moderator < Scope
    puts "Moderator Interaction policy"
    def resolve
      if user.present? && user.listed_reviewer?
        if user.moderator?
          #scope.under_revision
          puts "User is a moderator"
          scope.where(reviewer_id: user)
        else
          puts "User is no a moderator"
          scope.where(reviewer_id: user)
        end
      else
        puts "User is not present"
        scope.where(published: true)
      end
    end
  end

  class Embargo < Scope
    def resolve
      if user.present?
        if user.admin?
          scope.under_revision
        else
          scope.where(user_id: user)
        end
      else
        scope.where(published: true)
      end
    end
  end

  class Personal < Scope
    def resolve
      if user.present?
        if user.admin?
          scope.not_embargoed
        else
          scope.where(user_id: user)
        end
      else
        scope.published
      end
    end
  end

end
