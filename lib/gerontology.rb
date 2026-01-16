module Gerontology

 def fresh?
    self.updated_at > 1.week.ago
 end

 def young?
    self.created_at > 1.week.ago
 end

 def rot?
    self.updated_at < 1.month.ago
 end

 def old?
    self.created_at < 1.month.ago
 end

 def ripe?
    self.updated_at.between?(1.month.ago,1.week.ago)
 end

 def adult?
    self.created_at.between?(1.month.ago,1.week.ago)
 end

 def maturity
   if self.young?
     age = "young"
   elsif self.adult?
     age = "adult"
   elsif self.old?
     age = "old"
   end
   return age
 end

 def ripeness
   if self.fresh?
     age = "young"
   elsif self.ripe?
     age = "adult"
   elsif self.rot?
     age = "old"
   end
   return age
 end




end
