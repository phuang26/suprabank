class InteractionRelatedIdentifier < ActiveRecord::Base

belongs_to :interaction
belongs_to :related_identifier

end
