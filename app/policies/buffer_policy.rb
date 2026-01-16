class BufferPolicy < ApplicationPolicy

  def groupcheck
    if user.groups.present?
      if record.user.present?
        if record.user.groups.present?
          if user.groups.first == record.user.groups.first
            user.group_admin?
          end
        end
      end
    end
  end


  def update?
    if user.present?
      user.admin?  || user==record.user 
    end
  end


  def edit?
    update?
  end

end
