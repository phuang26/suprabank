class InteractionAdditive < ActiveRecord::Base
  belongs_to :interaction
  belongs_to :additive
  default_scope { order("concentration DESC NULLS LAST")}


    def additive_name
      self.additive.try(:display_name)
    end

    def additive_name=(name)
      if name.present?
        self.additive = Additive.find_by(display_name: name)
      else
        self.additive = nil
        self.concentration = nil
      end
    end

    def second_additive_name
      additive.try(:name)
    end

    def second_additive_name=(name)
      self.additive = Additive.find_by(display_name: name) if name.present?
    end

    def third_additive_name
      additive.try(:name)
    end

    def third_additive_name=(name)
      self.additive = Additive.find_by(display_name: name) if name.present?
    end

    def fourth_additive_name
      additive.try(:name)
    end

    def fourth_additive_name=(name)
      self.additive = Additive.find_by(display_name: name) if name.present?
    end

end
