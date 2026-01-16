class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def user_presence
    user.present?
  end

  def edit?
    record.update?
  end



  def groupcheck
    if user.groups.present?
      if record.user.groups.present?
        if user.groups.first == record.user.groups.first
          user.group_admin?
        end
      end
    end
  end


  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    if user.present?
      user.admin?  || user==record.user || user.editor? || groupcheck
    end
  end

  def edit?
    update?
  end

  def destroy?
    if user_presence
      user.admin?
    else
      false
    end
  end

  def editor_or_admin?
    if user_presence
      user.admin?  || user.editor?
    end
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end

end
