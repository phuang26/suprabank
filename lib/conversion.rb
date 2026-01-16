module Conversion

 def num_to_scinote(num)
   unless num.nan? || num.nil? || num == 0.0 
    log = Math.log10(num)
    expo = log.floor
    scie="%.2e" %num
    if (-3 <= expo && expo <= 3)
      scinote = num.to_s
    else
      if expo <= -10
        expoString = "-" + expo.to_s
      elsif expo.between?(-9,0)
        expoString = "-0" + expo.to_s
      elsif expo.between?(0,9)
        expoString = "+0" + expo.to_s
      elsif expo >= 10
        expoString = "+" + expo.to_s
      end
    subE="&sdot;10<sup>"
    expoSub = expo.to_s + "</sup>"
    scinote = scie.sub("e",subE).sub(expoString,expoSub)
    end
  else
    scinote = ""
  end
 end

 def unit_to_html(unit_str)
   unit_list = unit_str.split("-")
   unit = "#{unit_list[0]}<sup>-#{unit_list[1]}</sup>"
 end
 

end
