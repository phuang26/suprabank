class SolventPolicy < ApplicationPolicy

def update?
  if user.present?
    user.admin? || user.editor?
  end
end

def edit?
  update?
end

end
