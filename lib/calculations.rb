module Calculations

  def calc_deltaG
    self.deltaG = ((- 8.3145*(temperature+273.15)*Math.log(binding_constant))/1000).round(2)
  end


  def calc_deltaG_error
    if binding_constant_error.present?
      upperlimitLN = Math.log(binding_constant + binding_constant_error);
      lowerlimitLN = Math.log(binding_constant - binding_constant_error);
      self.deltaG_error = (8.3145 * (temperature+273.15) * ((upperlimitLN-lowerlimitLN)/2)/1000).round(2);
    end
  end

end
