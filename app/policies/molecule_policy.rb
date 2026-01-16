class MoleculePolicy < ApplicationPolicy
  
  def show?
    true
  end


  def index?
    true
  end

  def new?
    create?
  end

  def create?
    user.present?
  end


  def update?
      if user.present?
        user.admin? || user.editor? || record.user == user
      end
  end

  def edit?
    update?
  end


  class Scope < Scope
    puts "Scope Molecule policy"
    def resolve
      puts "Scope Molecule resolving"
      if user.present?
        puts "User is present"
        if user.admin? || user.editor?
          puts "User is admin or editor"
          scope.all
        else
          puts "User is neither admin nor editor"
          scope.where("interactions_count > ?", 0)
        end
      else
        puts "User is not present"
        scope.where("interactions_count > ?", 0)
      end
    end
  end

end




