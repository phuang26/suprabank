class BufferSolvent < ActiveRecord::Base
  belongs_to :solvent
  belongs_to :buffer
  default_scope { order("volume_percent DESC NULLS LAST")}

        def solvent_name
          self.solvent.try(:display_name)
        end

        def solvent_name=(name)
          if name.present?
            self.solvent = Solvent.find_by(display_name: name)
          else
            self.solvent = nil
            self.volume_percent = nil
          end
        end

        def second_solvent_name
          solvent.try(:name)
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
