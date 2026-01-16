function numToScinote (num) {
  var expo = Math.floor(Math.log10(num));
  var scie = num.toExponential(2)
  if (-3 <= expo && expo <= 3) {
    var scinote = num.toString()
  } else  {
      if (expo < 0) {
        var expoString = "-" + expo.toString()
      } else {
        var expoString = "+" + expo.toString()
      }
    var subE="&sdot;10<sup>"
    var expoSub = expo.toString() + "</sup>"
    var scinote = scie.toString().replace("e",subE).replace(expoString,expoSub)
  }
  return scinote
}
