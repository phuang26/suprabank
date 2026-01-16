class GroupPolicy < ApplicationPolicy

  def group_membership?
    if user.present? && user.groups.present?
      user.groups.first == record || user.admin?
    end
  end


end
