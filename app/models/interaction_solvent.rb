class InteractionSolvent < ActiveRecord::Base
  belongs_to :interaction
  belongs_to :solvent
  default_scope { order("volume_percent DESC NULLS LAST")}

      def first_solvent_name
        self.solvent.try(:display_name)
      end

      def first_solvent_name=(name)
        if name.present?
          self.solvent = Solvent.find_by(display_name: name)
        else
          self.solvent = nil
          self.volume_percent = nil
        end
      end

      def second_solvent_name
        #solvent.try(:name)
      end

      def second_solvent_name=(name)
        self.solvent = Solvent.find_by(display_name: name) if name.present?
      end

      def third_solvent_name
        solvent.try(:name)
      end

      def third_solvent_name=(name)
        self.solvent = Solvent.find_by(display_name: name) if name.present?
      end

      def fourth_solvent_name
        solvent.try(:name)
      end

      def fourth_solvent_name=(name)
        self.solvent = Solvent.find_by(display_name: name) if name.present?
      end
end
