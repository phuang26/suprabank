class BufferAdditive < ActiveRecord::Base
  belongs_to :additive
  belongs_to :buffer
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

end
