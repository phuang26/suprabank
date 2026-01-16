function between(x, min, max) {
  return ((x-min)*(x-max) <= 0);
};

var countDecimals = function (value) {
    if (value) {
      if ((value % 1) != 0)
          return value.toString().split(".")[1].length;
      return 0;
  };
};

function getExponent(number){
  var numInSciNot = {};
  var coefficient;
  var exponent;
  [coefficient, exponent] = number.toExponential().split('e').map(item => Number(item));
  return(exponent)
};



function errorPropAddSub(err1,err2){
  var error = Math.sqrt(Math.pow(err1,2)+Math.pow(err2,2))
  return(error)
};

function errorPropMulti(num1,num2,err1=0,err2=0){
  var error = (num1*num2)*Math.sqrt(Math.pow((err1/num1),2)+Math.pow((err2/num2),2))
  return(error)
};

function errorPropDiv(num1,num2,err1=0,err2=0){
  var error = (num1/num2)*Math.sqrt(Math.pow((err1/num1),2)+Math.pow((err2/num2),2))
  return(error)
};

function errorPropLN(num1,err1=0){
  var error = (err1/num1)
  return(error)
};

function errorPropLg(num1,err1=0){
  var error = 0.434 * errorPropLN(num1,err1)
  return(error)
};


function errorPropExp(num1,err1=0){
  var error = (err1*Math.exp(num1))
  return(error)
};

function errorPropDec(num1,err1=0){
  var error = 2.303*(err1*Math.pow(10,num1))
  return(error)
};


function calcfromkaerror(){
  if ($("#kaerror").val()) {
    var ka = parseFloat($("#ka").val().toString().replace(",", "."));
    var kd = parseFloat($("#kd").val().toString().replace(",", "."));
    var t = parseFloat($("#temperature").val()) + 273.15;
    var kaerror = parseFloat($("#kaerror").val().toString().replace(",", "."));
    var upperlimit10 = Math.log10(ka + kaerror);
    var lowerlimit10 = Math.log10(ka - kaerror);
    var logkaerror = (upperlimit10-lowerlimit10)/2 ;
    var upperlimitLN = Math.log(ka + kaerror);
    var lowerlimitLN = Math.log(ka - kaerror);
    var deltagerror = 8.3145 * t * ((upperlimitLN-lowerlimitLN)/2)/1000;
    var kderror = kd*(kaerror/ka);
    $("#kaerror").val(kaerror);
    $("#logkaerror").val((Math.round(logkaerror*100)/100).toFixed(2));
    $("#deltagerror").val((Math.round(deltagerror*100)/100).toFixed(2));
    $("#kderror").val(kderror.toPrecision(3));
  };
};

function calcfromlogkaerror(){
  if ($("#logkaerror").val()) {
      var logka = parseFloat($("#logka").val().toString().replace(",", "."));
      var ka = parseFloat($("#ka").val());
      var kd = parseFloat($("#kd").val());
      var t = parseFloat($("#temperature").val()) + 273.15;
      var logkaerror = parseFloat($("#logkaerror").val().toString().replace(",", "."));
      var upperlimit10 = Math.pow(10,(logka + logkaerror));
      var lowerlimit10 = Math.pow(10,(logka - logkaerror));
      var kaerror = (upperlimit10-lowerlimit10)/2 ;
      var upperlimitLN = Math.log(ka + kaerror);
      var lowerlimitLN = Math.log(ka - kaerror);
      var deltagerror = 8.3145 * t * ((upperlimitLN-lowerlimitLN)/2)/1000;
      var kderror = kd*(kaerror/ka);
      $("#logkaerror").val(logkaerror);
      $("#kaerror").val(kaerror.toPrecision(3));
      $("#deltagerror").val((Math.round(deltagerror*100)/100).toFixed(2));
      $("#kderror").val(kderror.toPrecision(3));
  };
};

function calcfromkderror(){
  if ($("#kderror").val()) {
    var kd = parseFloat($("#kd").val().toString().replace(",", "."));
    var ka = parseFloat($("#ka").val());
    var t = parseFloat($("#temperature").val()) + 273.15;
    var kderror = parseFloat($("#kderror").val().replace(",", "."));
    var kaerror = ka*(kderror/kd);
    var upperlimit10 = Math.log10(ka + kaerror);
    var lowerlimit10 = Math.log10(ka - kaerror);
    var logkaerror = (upperlimit10-lowerlimit10)/2 ;
    var upperlimitLN = Math.log(ka + kaerror);
    var lowerlimitLN = Math.log(ka - kaerror);
    var deltagerror = 8.3145 * t * ((upperlimitLN-lowerlimitLN)/2)/1000;
    $("#logkaerror").val((Math.round(logkaerror*100)/100).toFixed(2));
    $("#deltagerror").val((Math.round(deltagerror*100)/100).toFixed(2));
    $("#kaerror").val(kaerror.toPrecision(3));
    $("#kderror").val(kderror);
  };
};

function calcfromdeltaGerror(){
  if ($("#deltagerror").val()) {
    var deltagerror = parseFloat($("#deltagerror").val().replace(",", "."));
    var deltag = parseFloat($("#deltag").val().replace(",", "."));
    var ka = parseFloat($("#ka").val());
    var kd = parseFloat($("#kd").val());
    var t = parseFloat($("#temperature").val()) + 273.15;
    var lnK = deltag/(-8.3145*t/1000)
    var lnKerror = deltagerror/(-8.3145*t/1000)
    var upperlimitka = Math.exp(lnK + lnKerror);
    var lowerlimitka = Math.exp(lnK - lnKerror);
    var kaerror = Math.abs((upperlimitka-lowerlimitka)/2);
    var kderror = kd*(kaerror/ka);
    var upperlimit10 = Math.log10(ka + kaerror);
    var lowerlimit10 = Math.log10(ka - kaerror);
    var logkaerror = (upperlimit10-lowerlimit10)/2 ;
    $("#logkaerror").val((Math.round(logkaerror*100)/100).toFixed(2));
    $("#deltagerror").val(deltagerror);
    $("#kderror").val(kderror.toPrecision(3));
    $("#kaerror").val(kaerror.toPrecision(3));
  };
};


function calcToDecLog(source, target) {
  var result = Math.log10(parseFloat($(source).val()));
  $(target).val(parseFloat(Math.round(result*100)/100).toFixed(2));
}

function calcToDecPower(source, target) {
  var result = Math.pow(10,parseFloat($(source).val()));
  $(target).val(parseFloat(Math.round(result*100)/100).toFixed(2));
}



function calculatetolog(){
    var result =  Math.log10(parseFloat(document.getElementById('ka').value));
    document.getElementById('logka').value = parseFloat(Math.round(result*100)/100).toFixed(2);
  };

  function calculatetolog_upper(){
      var result =  Math.log10(parseFloat(document.getElementById('ka_upper').value));
      document.getElementById('logka_upper').value = parseFloat(Math.round(result*100)/100).toFixed(2);
    };

  function calculatetologerror(){
      var upperlimit10 = Math.log10(parseFloat(document.getElementById('ka').value)+parseFloat(document.getElementById('kaerror').value)) - parseFloat(document.getElementById('logka').value);
      var lowerlimit10 = parseFloat(document.getElementById('logka').value) - Math.log10(parseFloat(document.getElementById('ka').value)-parseFloat(document.getElementById('kaerror').value));
      var result10 = (upperlimit10+lowerlimit10)/2 ;
      document.getElementById('logkaerror').value = parseFloat(Math.round(result10*100)/100).toFixed(2);
      var upperlimitLN = Math.log(parseFloat(document.getElementById('ka').value)+parseFloat(document.getElementById('kaerror').value)) - Math.log(parseFloat(document.getElementById('ka').value));
      var lowerlimitLN = Math.log(parseFloat(document.getElementById('ka').value)) - Math.log(parseFloat(document.getElementById('ka').value)-parseFloat(document.getElementById('kaerror').value));
      var resultLN = (upperlimitLN+lowerlimitLN)/2 ;
      var deltaGerror = resultLN*8.3145*(parseFloat(document.getElementById('temperature').value)+273.15)/1000;
      document.getElementById('deltagerror').value = parseFloat(Math.round(deltaGerror*100)/100).toFixed(2);
    };





function calcfromkd(){
  if ($("#kd").val()) {
    var kd = parseFloat($("#kd").val().toString().replace(",", "."));
    var ka = (1/parseFloat($("#kd").val().toString().replace(",", ".")));
    var logka = Math.log10(ka);
    var t = parseFloat($("#temperature").val());
    var deltag = Math.log(ka)*-8.3145*(t+273.15)/1000;
    $("#kd").val(kd);
    $("#ka").val(ka.toPrecision(4));
    $("#logka").val((Math.round(logka*100)/100).toFixed(2));
    $("#deltag").val((Math.round(deltag*100)/100).toFixed(2));
    !$("#ka").hasClass(".calculatedG") || $("#ka").removeClass(".calculatedG");
    $("#deltag").hasClass(".calculatedG") || $("#deltag").addClass(".calculatedG");
  };

};

function calcfromka(){
  if ($("#ka").val()) {
    var ka = parseFloat($("#ka").val().replace(",", "."));
    var kd = (1/ka);
    var logka = Math.log10(ka);
    var t = parseFloat($("#temperature").val());
    var deltag = Math.log(ka)*-8.3145*(t+273.15)/1000;
    $("#kd").val(kd.toPrecision(4));
    $("#ka").val(ka);
    $("#logka").val((Math.round(logka*100)/100).toFixed(2));
    $("#deltag").val((Math.round(deltag*100)/100).toFixed(2));
    $("#deltag").hasClass(".calculatedG") || $("#deltag").addClass(".calculatedG");
    !$("#ka").hasClass(".calculatedG") || $("#ka").removeClass(".calculatedG");
  };
};

function calcfromdeltaG(){
  if ($("#deltag").val()) {
    var deltag = parseFloat($("#deltag").val().replace(",", "."));
    var t = parseFloat($("#temperature").val());
    var lnK = deltag/(-8.3145*(t+273.15)/1000)
    var ka = Math.exp(lnK)
    var kd = (1/ka);
    var logka = Math.log10(ka);
    $("#kd").val(kd.toPrecision(4));
    $("#ka").val(ka.toPrecision(4));
    $("#logka").val((Math.round(logka*100)/100).toFixed(2));
    $("#deltag").val(deltag);
    $("#ka").hasClass(".calculatedG") || $("#ka").addClass(".calculatedG");
    !$("#deltag").hasClass(".calculatedG") || $("#deltag").removeClass(".calculatedG");
  };
};

function calcfromlogka(){
    if ($("#logka").val()) {
      var logka = parseFloat($("#logka").val().toString().replace(",", "."));
      var ka =  Math.pow(10,logka);
      var kd = (1/ka);
      var t = parseFloat($("#temperature").val());
      var deltag = Math.log(ka)*-8.3145*(t+273.15)/1000;
      $("#kd").val(kd.toPrecision(4));
      $("#ka").val(ka.toPrecision(4));
      $("#logka").val(logka);
      $("#deltag").val((Math.round(deltag*100)/100).toFixed(2));
      $("#deltag").hasClass(".calculatedG") || $("#deltag").addClass(".calculatedG");
      !$("#ka").hasClass(".calculatedG") || $("#ka").removeClass(".calculatedG");
    };
};

$(document).on('turbolinks:load',function(){
  calcfromka();
});

$(document).on('turbolinks:load',function(){
  calcfromkaerror();
});

function checkAboveZero(){
    if ($("#ka").val()) {
      var ka = parseFloat($("#ka").val().replace(",", "."));
      if (ka <= 0) {
        if (!$("#ka").hasClass(".unvalidNum")) {
         $("#ka").addClass("errorbox");
         $("#ka").closest(".form-group").after('<div class="form-group"> <div class="col-md-8 col-md-offset-2 checkzero"><p><em>K</em><sub>a</sub> has to be greater than zero.<br> If binding takes place, but <em>K</em><sub>a</sub> is unknown, please choose <em>K</em><sub>a</sub> > 1 and add a comment that <em>K</em><sub>a</sub> is unknown. If there is no interaction/binding, please enter <em>K</em><sub>a</sub> &lt; 0.001.</p></div></div>');
         $("#ka").addClass(".unvalidNum");
        };
      } else if (!isFinite(ka)) {
        if (!$("#kd").hasClass(".unvalidNum")) {
         $("#kd").addClass("errorbox");
         $("#kd").closest(".form-group").after('<div class="form-group"> <div class="col-md-8 col-md-offset-2 checkzero"><p><em>K</em><sub>d</sub> has to be greater than zero.</p></div></div>');
         $("#kd").addClass(".unvalidNum");
        };
      } else {
        if ($("#ka").hasClass(".unvalidNum")) {
          $("#ka").removeClass("errorbox");
          $("#ka").closest(".form-group").next().remove();
          $("#ka").removeClass(".unvalidNum");
          };
        if ($("#kd").hasClass(".unvalidNum")) {
          $("#kd").removeClass("errorbox");
          $("#kd").closest(".form-group").next().remove();
          $("#kd").removeClass(".unvalidNum");
        };
      }
    }
};

function checkValidNumber(idofnum){
     var numcorrect = idofnum.value.toString().replace(",", ".");
     if (!isFinite(numcorrect) || (numcorrect < 0) ) {
         idofnum.value=0;
         if (!$(idofnum).hasClass(".unvalidNum")) {
          $(idofnum).addClass("errorbox");
          $(idofnum).closest(".form-group").after('<div class="form-group"> <div class="col-md-10 col-md-offset-2 checkzero"><p> Please enter a valid number. Otherwise, it will be saved as 0. </p></div></div>');
          $(idofnum).addClass(".unvalidNum");
         };
       } else {
        idofnum.value=numcorrect;
        if ($(idofnum).hasClass(".unvalidNum")) {
          $(idofnum).removeClass("errorbox");
          $(idofnum).closest(".form-group").next().remove();
          $(idofnum).removeClass(".unvalidNum");
        }
     };
 };

 function checkValidNumberbelow(idofnum){
      var numcorrect = idofnum.value.toString().replace(",", ".");
      if (!isFinite(numcorrect)) {
          idofnum.value=0;
          if (!$(idofnum).hasClass(".unvalidNum")) {
           $(idofnum).addClass("errorbox");
           $(idofnum).closest(".form-group").after('<div class="form-group"> <div class="col-md-10 col-md-offset-2 checkzero"><p> Please enter a valid number. Otherwise, it will be saved as 0. </p></div></div>');
           $(idofnum).addClass(".unvalidNum");
          };
        } else {
         idofnum.value=numcorrect;
         if ($(idofnum).hasClass(".unvalidNum")) {
           $(idofnum).removeClass("errorbox");
           $(idofnum).closest(".form-group").next().remove();
           $(idofnum).removeClass(".unvalidNum");
         };
      };
  };


  function checkConcRelation() {
    if (isFinite(parseFloat(document.getElementById('interaction_upper_molecule_concentration').value)) && isFinite(parseFloat(document.getElementById('interaction_lower_molecule_concentration').value)) && (parseFloat(document.getElementById('interaction_lower_molecule_concentration').value) >= parseFloat(document.getElementById('interaction_upper_molecule_concentration').value))) {
       if (!$("#interaction_upper_molecule_concentration").hasClass(".wrongConcRel")){
         $("#interaction_upper_molecule_concentration").addClass("errorbox");
         $("#interaction_upper_molecule_concentration").closest(".form-group").after('<div class="form-group"> <div class="col-md-10 col-md-offset-2 checkzero"><p> The upper molecule concentration shall be greater than the lower molecule concentration.</p></div></div>');
         $("#interaction_upper_molecule_concentration").addClass(".wrongConcRel");
       };
       return;
    } else {
        if ($("#interaction_upper_molecule_concentration").hasClass(".wrongConcRel")){
           $("#interaction_upper_molecule_concentration").removeClass("errorbox");
           $("#interaction_upper_molecule_concentration").closest(".form-group").next().remove();
           $("#interaction_upper_molecule_concentration").removeClass(".wrongConcRel");
        };
    };
    if (isFinite(parseFloat(document.getElementById('interaction_upper_host_concentration').value)) && isFinite(parseFloat(document.getElementById('interaction_lower_host_concentration').value)) && (parseFloat(document.getElementById('interaction_lower_host_concentration').value) >= parseFloat(document.getElementById('interaction_upper_host_concentration').value))) {
       if (!$("#interaction_upper_host_concentration").hasClass(".wrongConcRel")){
         $("#interaction_upper_host_concentration").addClass("errorbox");
         $("#interaction_upper_host_concentration").closest(".form-group").after('<div class="form-group"> <div class="col-md-10 col-md-offset-2 checkzero"><p> The upper host concentration shall be greater than the lower host concentration.</p></div></div>');
         $("#interaction_upper_host_concentration").addClass(".wrongConcRel");
       };
       return;
    } else {
        if ($("#interaction_upper_host_concentration").hasClass(".wrongConcRel")){
           $("#interaction_upper_host_concentration").removeClass("errorbox");
           $("#interaction_upper_host_concentration").closest(".form-group").next().remove();
           $("#interaction_upper_host_concentration").removeClass(".wrongConcRel");
        };
    };
    if (isFinite(parseFloat(document.getElementById('interaction_upper_indicator_concentration').value)) && isFinite(parseFloat(document.getElementById('interaction_lower_indicator_concentration').value)) && (parseFloat(document.getElementById('interaction_lower_indicator_concentration').value) >= parseFloat(document.getElementById('interaction_upper_indicator_concentration').value))) {
       if (!$("#interaction_upper_indicator_concentration").hasClass(".wrongConcRel")){
         $("#interaction_upper_indicator_concentration").addClass("errorbox");
         $("#interaction_upper_indicator_concentration").closest(".form-group").after('<div class="form-group"> <div class="col-md-10 col-md-offset-2 checkzero"><p> The upper indicator concentration shall be greater than the lower indicator concentration.</p></div></div>');
         $("#interaction_upper_indicator_concentration").addClass(".wrongConcRel");
       };
       return;
    } else {
        if ($("#interaction_upper_indicator_concentration").hasClass(".wrongConcRel")){
           $("#interaction_upper_indicator_concentration").removeClass("errorbox");
           $("#interaction_upper_indicator_concentration").closest(".form-group").next().remove();
           $("#interaction_upper_indicator_concentration").removeClass(".wrongConcRel");
        };
    };
    if (isFinite(parseFloat(document.getElementById('interaction_upper_conjugate_concentration').value)) && isFinite(parseFloat(document.getElementById('interaction_lower_conjugate_concentration').value)) && (parseFloat(document.getElementById('interaction_lower_conjugate_concentration').value) >= parseFloat(document.getElementById('interaction_upper_conjugate_concentration').value))) {
       if (!$("#interaction_upper_conjugate_concentration").hasClass(".wrongConcRel")){
         $("#interaction_upper_conjugate_concentration").addClass("errorbox");
         $("#interaction_upper_conjugate_concentration").closest(".form-group").after('<div class="form-group"> <div class="col-md-10 col-md-offset-2 checkzero"><p> The upper conjugate concentration shall be greater than the lower conjugate concentration.</p></div></div>');
         $("#interaction_upper_conjugate_concentration").addClass(".wrongConcRel");
       };
       return;
    } else {
        if ($("#interaction_upper_conjugate_concentration").hasClass(".wrongConcRel")){
           $("#interaction_upper_conjugate_concentration").removeClass("errorbox");
           $("#interaction_upper_conjugate_concentration").closest(".form-group").next().remove();
           $("#interaction_upper_conjugate_concentration").removeClass(".wrongConcRel");
        };
    };
};



function range_ka(){
  var range = $("#interaction_binding_range").val();
    switch (range) {
      case 'equal':
        $("#dissociation_range").val('equal');
        $("#logka_range").val('equal');
        $("#deltag_range").val('equal');
        break;
      case 'less':
        $("#dissociation_range").val('greater');
        $("#logka_range").val('less');
        $("#deltag_range").val('greater');
        break;
      case 'greater':
        $("#dissociation_range").val('less');
        $("#logka_range").val('greater');
        $("#deltag_range").val('less');
        break;
    };
};

$(document).on('turbolinks:load',function(){
  range_ka();
});

function range_logka(){
  var range = $("#logka_range").val();
    switch (range) {
      case 'equal':
        $("#dissociation_range").val('equal');
        $("#interaction_binding_range").val('equal');
        $("#deltag_range").val('equal');
        break;
      case 'less':
        $("#dissociation_range").val('greater');
        $("#interaction_binding_range").val('less');
        $("#deltag_range").val('greater');
        break;
      case 'greater':
        $("#dissociation_range").val('less');
        $("#interaction_binding_range").val('greater');
        $("#deltag_range").val('less');
        break;
    };
};

function range_kd(){
  var range = $("#dissociation_range").val();
    switch (range) {
      case 'equal':
        $("#interaction_binding_range").val('equal');
        $("#logka_range").val('equal');
        $("#deltag_range").val('equal');
        break;
      case 'less':
        $("#interaction_binding_range").val('greater');
        $("#logka_range").val('greater');
        $("#deltag_range").val('less');
        break;
      case 'greater':
        $("#interaction_binding_range").val('less');
        $("#logka_range").val('less');
        $("#deltag_range").val('greater');
        break;
      }
};

function range_deltag(){
  var range = $("#deltag_range").val();
    switch (range) {
      case 'equal':
        $("#interaction_binding_range").val('equal');
        $("#logka_range").val('equal');
        $("#dissociation_range").val('equal');
        break;
      case 'less':
        $("#interaction_binding_range").val('greater');
        $("#logka_range").val('greater');
        $("#dissociation_range").val('less');
        break;
      case 'greater':
        $("#interaction_binding_range").val('less');
        $("#logka_range").val('less');
        $("#dissociation_range").val('greater');
        break;
      }
};

function TfromC(){
  if ($("#temperature").val()) {
    var tC = parseFloat($("#temperature").val().toString().replace(",", "."));
    var tK = tC + 273.15;
    $("#temperature").val(tC);
    $("#cond_TempK").val((Math.round(tK*100)/100).toFixed(countDecimals(tC)));
  };
};

function TfromK(){
  if ($("#cond_TempK").val()) {
    var tK = parseFloat($("#cond_TempK").val().toString().replace(",", "."));
    var tC = tK - 273.15;
    $("#cond_TempK").val(tK);
    $("#temperature").val((Math.round(tC*100)/100).toFixed(countDecimals(tK)));
  };
};

function GfromT(){
  if ($("#temperature").val() && $("#ka").val() && !$("#ka").hasClass(".calculatedG")) {
    var tK = parseFloat($("#temperature").val())+273.15;
    var ka = parseFloat($("#ka").val());
    var deltag = Math.log(ka)*-8.3145*(tK)/1000;
    $("#deltag").val((Math.round(deltag*100)/100).toFixed(2));
    if ($("#kaerror").val()) {
      var ka = parseFloat($("#ka").val());
      var kaerror = parseFloat($("#kaerror").val());
      var upperlimit10 = Math.log10(ka + kaerror);
      var lowerlimit10 = Math.log10(ka - kaerror);
      var logkaerror = (upperlimit10-lowerlimit10)/2 ;
      var upperlimitLN = Math.log(ka + kaerror);
      var lowerlimitLN = Math.log(ka - kaerror);
      var deltagerror = 8.3145 * tK * ((upperlimitLN-lowerlimitLN)/2)/1000;
      $("#deltagerror").val((Math.round(deltagerror*100)/100).toFixed(2));
    };
  }
  else if ($("#temperature").val() && $("#deltag").val() && !$("#deltag").hasClass(".calculatedG")) {
    var tK = parseFloat($("#temperature").val())+273.15;
    var deltag = parseFloat($("#deltag").val());
    var lnK = deltag/(-8.3145*(tK)/1000)
    var ka = Math.exp(lnK)
    var ka_expo = Math.abs(getExponent(ka));
    var kd = (1/ka);
    var logka = Math.log10(ka);
    $("#kd").val((kd.toFixed(ka_expo+4)));
    $("#ka").val((Math.round(ka*100)/100).toFixed(2));
    $("#logka").val((Math.round(logka*100)/100).toFixed(2));
    if ($("#deltagerror").val()) {
      var deltagerror = parseFloat($("#deltagerror").val());
      var lnKerror = deltagerror/(-8.3145*tK/1000)
      var upperlimitka = Math.exp(lnK + lnKerror);
      var lowerlimitka = Math.exp(lnK - lnKerror);
      var kaerror = Math.abs((upperlimitka-lowerlimitka)/2);
      var kderror = kd*(kaerror/ka);
      var upperlimit10 = Math.log10(ka + kaerror);
      var lowerlimit10 = Math.log10(ka - kaerror);
      var logkaerror = (upperlimit10-lowerlimit10)/2 ;
      $("#logkaerror").val((Math.round(logkaerror*100)/100).toFixed(2));
      $("#kaerror").val((Math.round(kaerror*100)/100).toFixed(2));
      $("#kderror").val((Math.round(kderror*100)/100).toFixed(2));
    }
  };

  if ($("#temperature").val() && $("#deltaST").val() && !$("#deltaST").hasClass(".calculatedS")) {
    var tK = parseFloat($("#temperature").val())+273.15;
    var dTS = parseFloat($("#deltaST").val());
    var pureS = - dTS*1000/tK;
    var pureScal = pureS * 0.2390057;
    $("#itc_pureS").val((Math.round(pureS*100)/100).toFixed(countDecimals(dTS)));
    $("#itc_pureScal").val((Math.round(pureScal*100)/100).toFixed(countDecimals(dTS)));
    if ($("#interaction_itc_deltaST_error").val()) {
      var dTSerror = parseFloat($("#interaction_itc_deltaST_error").val());
      var pureSerror = dTSerror*1000/tK;
      var pureScalerror = pureSerror * 0.2390057;
      $("#itc_pureS_error").val((Math.round(pureSerror*100)/100).toFixed(countDecimals(dTSerror)));
      $("#itc_pureScal_error").val((Math.round(pureScalerror*100)/100).toFixed(countDecimals(dTSerror)));
    }
  } else if ($("#temperature").val() && $("#itc_pureS").val() && !$("#itc_pureS").hasClass(".calculatedS")) {
    var tK = parseFloat($("#temperature").val())+273.15;
    var pureS = parseFloat($("#itc_pureS").val());
    var dTS = - pureS/1000*tK;
    var dTScal = dTS * 0.2390057;
    $("#deltaST").val((Math.round(dTS*100)/100).toFixed(countDecimals(pureS)));
    $("#itc_itc_deltaSTcal").val((Math.round(dTScal*100)/100).toFixed(countDecimals(pureS)));
    if ($("#itc_pureS_error").val()) {
      var pureSerror = parseFloat($("#itc_pureS_error").val());
      var dTSerror = pureSerror/1000*tK;
      var kcal_dTSerror = dTSerror * 0.2390057;
      $("#interaction_itc_deltaST_error").val((Math.round(dTSerror*100)/100).toFixed(countDecimals(pureSerror)));
      $("#itc_deltaSTcal_error").val((Math.round(kcal_dTSerror*100)/100).toFixed(countDecimals(pureSerror)));
    }
  };

};

$(document).on('turbolinks:load',function(){
  TfromC();
});

function fromdHkJ(){
  if ($("#interaction_itc_deltaH").val()) {
    var dH = parseFloat($("#interaction_itc_deltaH").val().toString().replace(",", "."));
    var kcal_dH = dH * 0.2390057;
    $("#itc_deltaH_kcal").val((Math.round(kcal_dH*100)/100).toFixed(countDecimals(dH)));
    $("#interaction_itc_deltaH").val(dH);
  };
};



function fromdHkcal(){
  if ($("#itc_deltaH_kcal").val()) {
    var kcal_dH = parseFloat($("#itc_deltaH_kcal").val().toString().replace(",", "."));
    var dH = kcal_dH / 0.2390057;
    $("#interaction_itc_deltaH").val((Math.round(dH*100)/100).toFixed(countDecimals(kcal_dH)));
    $("#itc_deltaH_kcal").val(kcal_dH);
  };
};


$(document).on('turbolinks:load',function(){
  fromdHkJ();
});

function frompureSkcal(){
  if ($("#itc_pureScal").val()) {
    var kcal_dS = parseFloat($("#itc_pureScal").val().toString().replace(",", "."));
    var dS = kcal_dS / 0.2390057;
    var kcal_dTS = -kcal_dS/1000*(parseFloat(document.getElementById('temperature').value)+273.15);
    var dTS = kcal_dTS / 0.2390057;
    $("#deltaST").val((Math.round(dTS*100)/100).toFixed(countDecimals(kcal_dS)));
    $("#itc_pureS").val((Math.round(dS*100)/100).toFixed(countDecimals(kcal_dS)));
    $("#itc_pureScal").val(kcal_dS);
    $("#itc_deltaSTcal").val((Math.round(kcal_dTS*100)/100).toFixed(countDecimals(kcal_dS)));
    $("#deltaST").hasClass(".calculatedS") || $("#deltaST").addClass(".calculatedS");
    !$("#itc_pureS").hasClass(".calculatedS") || $("#itc_pureS").removeClass(".calculatedS");
  };
};


function fromdTSkcal(){
  if ($("#itc_deltaSTcal").val()) {
    var kcal_dTS = parseFloat($("#itc_deltaSTcal").val().toString().replace(",", "."));
    var dTS = kcal_dTS / 0.2390057;
    var kcal_dS = -kcal_dTS*1000/(parseFloat(document.getElementById('temperature').value)+273.15);
    var dS = kcal_dS / 0.2390057;
    $("#deltaST").val((Math.round(dTS*100)/100).toFixed(countDecimals(kcal_dTS)));
    $("#itc_pureS").val((Math.round(dS*100)/100).toFixed(countDecimals(kcal_dTS)));
    $("#itc_pureScal").val((Math.round(kcal_dS*100)/100).toFixed(countDecimals(kcal_dTS)));
    $("#itc_deltaSTcal").val(kcal_dTS);
    !$("#deltaST").hasClass(".calculatedS") || $("#deltaST").removeClass(".calculatedS");
    $("#itc_pureS").hasClass(".calculatedS") || $("#itc_pureS").addClass(".calculatedS");
  };
};


function frompureSkJ(){
  if ($("#itc_pureS").val()) {
    var dS = parseFloat($("#itc_pureS").val().toString().replace(",", "."));
    var kcal_dS = dS * 0.2390057;
    var dTS = -dS/1000*(parseFloat(document.getElementById('temperature').value)+273.15);
    var kcal_dTS = dTS * 0.2390057;
    $("#itc_deltaSTcal").val((Math.round(kcal_dTS*100)/100).toFixed(countDecimals(dS)));
    $("#itc_pureS").val(dS);
    $("#itc_pureScal").val((Math.round(kcal_dS*100)/100).toFixed(countDecimals(dS)));
    $("#deltaST").val((Math.round(dTS*100)/100).toFixed(countDecimals(dS)));

    $("#deltaST").hasClass(".calculatedS") || $("#deltaST").addClass(".calculatedS");
    !$("#itc_pureS").hasClass(".calculatedS") || $("#itc_pureS").removeClass(".calculatedS");
  };
};


function fromdTSkJ(){
  if ($("#deltaST").val()) {
    var dTS = parseFloat($("#deltaST").val().toString().replace(",", "."));
    var kcal_dTS = dTS * 0.2390057;
    var dS = -dTS*1000/(parseFloat(document.getElementById('temperature').value)+273.15);
    var kcal_dS = dS * 0.2390057;
    $("#itc_deltaSTcal").val((Math.round(kcal_dTS*100)/100).toFixed(countDecimals(dTS)));
    $("#itc_pureS").val((Math.round(dS*100)/100).toFixed(countDecimals(dTS)));
    $("#itc_pureScal").val((Math.round(kcal_dS*100)/100).toFixed(countDecimals(dTS)));
    $("#deltaST").val(dTS);
    !$("#deltaST").hasClass(".calculatedS") || $("#deltaST").removeClass(".calculatedS");
    $("#itc_pureS").hasClass(".calculatedS") || $("#itc_pureS").addClass(".calculatedS");
  };
};


$(document).on('turbolinks:load',function(){
  fromdTSkJ();
});

function fromdHkJerror(){
  if ($("#interaction_itc_deltaH_error").val()) {
    var dHerror = parseFloat($("#interaction_itc_deltaH_error").val().toString().replace(",", "."));
    var kcal_dHerror = dHerror * 0.2390057;
    $("#itc_deltaH_kcal_error").val((Math.round(kcal_dHerror*100)/100).toFixed(countDecimals(dHerror)));
    $("#interaction_itc_deltaH_error").val(dHerror);
  };
};


$(document).on('turbolinks:load',function(){
  fromdHkJerror();
});


function fromdTSkJerror(){
  if ($("#interaction_itc_deltaST_error").val()) {
    var dTSerror = parseFloat($("#interaction_itc_deltaST_error").val().toString().replace(",", "."));
    var kcal_dTSerror = dTSerror * 0.2390057;
    var pureSerror = dTSerror*1000/(parseFloat(document.getElementById('temperature').value)+273.15);
    var pureScalerror = pureSerror * 0.2390057;
    $("#interaction_itc_deltaST_error").val(dTSerror);
    $("#itc_deltaSTcal_error").val((Math.round(kcal_dTSerror*100)/100).toFixed(countDecimals(dTSerror)));
    $("#itc_pureS_error").val((Math.round(pureSerror*100)/100).toFixed(countDecimals(dTSerror)));
    $("#itc_pureScal_error").val((Math.round(pureScalerror*100)/100).toFixed(countDecimals(dTSerror)));
  };
};

$(document).on('turbolinks:load',function(){
  fromdTSkJerror();
});


function fromdHkcalerror(){
  if ($("#itc_deltaH_kcal_error").val()) {
    var kcal_dHerror = parseFloat($("#itc_deltaH_kcal_error").val().toString().replace(",", "."));
    var dHerror = kcal_dHerror / 0.2390057;
    $("#interaction_itc_deltaH_error").val((Math.round(dHerror*100)/100).toFixed(countDecimals(kcal_dHerror)));
    $("#itc_deltaH_kcal_error").val(kcal_dHerror);
  };
};


function fromdTSkcalerror(){
  if ($("#itc_deltaSTcal_error").val()) {
    var kcal_dTSerror = parseFloat($("#itc_deltaSTcal_error").val().toString().replace(",", "."));
    var dTSerror = kcal_dTSerror/0.2390057;
    var pureScalerror = kcal_dTSerror*1000/(parseFloat(document.getElementById('temperature').value)+273.15);
    var pureSerror = pureScalerror / 0.2390057;
    $("#interaction_itc_deltaST_error").val((Math.round(dTSerror*100)/100).toFixed(countDecimals(kcal_dTSerror)));
    $("#itc_deltaSTcal_error").val(kcal_dTSerror);
    $("#itc_pureS_error").val((Math.round(pureSerror*100)/100).toFixed(countDecimals(kcal_dTSerror)));
    $("#itc_pureScal_error").val((Math.round(pureScalerror*100)/100).toFixed(countDecimals(kcal_dTSerror)));
  };
};

function frompureSkcalerror(){
  if ($("#itc_pureScal_error").val()) {
    var pureScalerror = parseFloat($("#itc_pureScal_error").val().toString().replace(",", "."));
    var pureSerror = pureScalerror / 0.2390057;
    var kcal_dTSerror = pureScalerror/1000*(parseFloat(document.getElementById('temperature').value)+273.15);
    var dTSerror = kcal_dTSerror / 0.2390057;
    $("#interaction_itc_deltaST_error").val((Math.round(dTSerror*100)/100).toFixed(countDecimals(pureScalerror)));
    $("#itc_deltaSTcal_error").val((Math.round(kcal_dTSerror*100)/100).toFixed(countDecimals(pureScalerror)));
    $("#itc_pureS_error").val((Math.round(pureSerror*100)/100).toFixed(countDecimals(pureScalerror)));
    $("#itc_pureScal_error").val(pureScalerror);
  };
};

function frompureSkJerror(){
  if ($("#itc_pureS_error").val()) {
    var pureSerror = parseFloat($("#itc_pureS_error").val().toString().replace(",", "."));
    var pureScalerror = pureSerror * 0.2390057;
    var dTSerror = pureSerror/1000*(parseFloat(document.getElementById('temperature').value)+273.15);
    var kcal_dTSerror = dTSerror * 0.2390057;
    $("#interaction_itc_deltaST_error").val((Math.round(dTSerror*100)/100).toFixed(countDecimals(pureSerror)));
    $("#itc_deltaSTcal_error").val((Math.round(kcal_dTSerror*100)/100).toFixed(countDecimals(pureSerror)));
    $("#itc_pureS_error").val(pureSerror);
    $("#itc_pureScal_error").val((Math.round(pureScalerror*100)/100).toFixed(countDecimals(pureSerror)));
  };
};

function deltaGConsisticyCheck() {
  if ($("#deltag").val()) {
    if ($("#deltaST").val()) {
      if ($("#interaction_itc_deltaH").val()) {
        var deltaG = parseFloat($("#deltag").val());
        var max = deltaG * 1.25;
        var min = deltaG * 0.75;
        var dTS = parseFloat($("#deltaST").val());
        var dH = parseFloat($("#interaction_itc_deltaH").val());
        var comValue  = dH + dTS;
        if (between(comValue, min, max)) {
          $("#error_message_thermodynamics").html("")
          $("#deltag").removeClass("error_frame")
          $("#deltaST").removeClass("error_frame")
          $("#interaction_itc_deltaH").removeClass("error_frame")
        } else {
          $("#error_message_thermodynamics").html("Attention:  &#916;<em>G</em> &#8800 &#916;<em>H</em> - T &middot &#916;<em>S</em>. Please check your thermodynamic parameters for typos and signs.")
          $("#deltag").addClass("error_frame")
          $("#deltaST").addClass("error_frame")
          $("#interaction_itc_deltaH").addClass("error_frame")
        };

      };
    };
  };
};

$(document).on('turbolinks:load',function(){
    deltaGConsisticyCheck();
});


function commaConversion(){
  alter($(this).val());
};


  function calculatetodec(){
      var result = Math.pow(10,parseFloat(document.getElementById('logka').value));
      document.getElementById('ka').value =  parseFloat(Math.round(result*100)/100).toFixed(2);
      var deltaG = Math.log(parseFloat(document.getElementById('ka').value))*-8.3145*(parseFloat(document.getElementById('temperature').value)+273.15)/1000;
      document.getElementById('deltag').value = parseFloat(Math.round(deltaG*100)/100).toFixed(2);
    };

  function calculatetodec_upper(){
      var result = Math.pow(10,parseFloat(document.getElementById('logka_upper').value));
      document.getElementById('ka_upper').value =  parseFloat(Math.round(result*100)/100).toFixed(2);
      var deltaG = Math.log(parseFloat(document.getElementById('ka_upper').value))*-8.3145*(parseFloat(document.getElementById('temperature').value)+273.15)/1000;
      document.getElementById('deltag').value = parseFloat(Math.round(deltaG*100)/100).toFixed(2);
    };

  function calculatetodecerror(){
      var upperlimit10 = Math.pow(10,(parseFloat(document.getElementById('logka').value)+parseFloat(document.getElementById('logkaerror').value))) - parseFloat(document.getElementById('ka').value);
      var lowerlimit10 = parseFloat(document.getElementById('ka').value) - Math.pow(10,(parseFloat(document.getElementById('logka').value)-parseFloat(document.getElementById('logkaerror').value)));
      var result10 = (upperlimit10+lowerlimit10)/2 ;
      document.getElementById('kaerror').value = parseFloat(Math.round(result10*100)/100).toFixed(2);
      var upperlimitLN = Math.log(parseFloat(document.getElementById('ka').value)+parseFloat(document.getElementById('kaerror').value)) - Math.log(parseFloat(document.getElementById('ka').value));
      var lowerlimitLN = Math.log(parseFloat(document.getElementById('ka').value)) - Math.log(parseFloat(document.getElementById('ka').value)-parseFloat(document.getElementById('kaerror').value));
      var resultLN = (upperlimitLN+lowerlimitLN)/2 ;
      var deltaGerror = resultLN*8.3145*(parseFloat(document.getElementById('temperature').value)+273.15)/1000;
      document.getElementById('deltagerror').value = parseFloat(Math.round(deltaGerror*100)/100).toFixed(2);

    };

    function calculatekhgout(){
      var kgiven = parseFloat(document.getElementById('interaction_kin_hg').value);

      if (isFinite(kgiven)) {
        var result = (kgiven / document.getElementById('ka').value);
        document.getElementById('interaction_kout_hg').value =  result;
      } else {
        document.getElementById('interaction_kout_hg').value =  "";
      };
    };

    function calculatekhgin(){
      var kgiven = parseFloat(document.getElementById('interaction_kout_hg').value);
    
      if (isFinite(kgiven)) {
        var result = document.getElementById('ka').value * kgiven;
        document.getElementById('interaction_kin_hg').value =  result;
      } else {
        document.getElementById('interaction_kin_hg').value =  "";
      };
    };

    function numtoscientific(i, num){
        var expterm = Math.log10(num);
        var decimalPart = expterm - Math.floor(expterm);

        if (decimalPart > 0.5) {
          var n = Math.round(expterm)-1;
        } else {
          var n = Math.round(expterm);
        }
        var m = (num / (Math.pow(10,n))).toFixed(2);

        if ( num < 0.001 && i === 'ScientificKa'){
          document.getElementById(i).innerHTML = '<strong>' + m.toString() +'&sdot;10<sup>'+n.toString()+'</sup> </strong>' ;
        } else if ( num < 0.001) {
          document.getElementById(i).innerHTML = '<strong> &#177; ' + m.toString() +'&sdot;10<sup>'+n.toString()+'</sup> </strong>' ;
        } else if (num < 1000 && i === 'ScientificKa'){
          document.getElementById(i).innerHTML = '<strong>' + num.toString() +'</strong>' ;
        } else if ( num < 1000){
          document.getElementById(i).innerHTML = '<strong> &#177; ' + num.toString() +'</strong>' ;
        } else if ( i === 'ScientificKa'){
          document.getElementById(i).innerHTML = '<strong>' + m.toString() +'&sdot;10<sup>'+n.toString()+'</sup> </strong>' ;
        } else {
          document.getElementById(i).innerHTML = '<strong> &#177; ' + m.toString() +'&sdot;10<sup>'+n.toString()+'</sup> </strong>' ;
        }
      };

   function numtoscientificTable(table, i, num, unit){
              var expterm = Math.log10(num);
              var decimalPart = expterm - Math.floor(expterm);

              if (decimalPart > 0.5) {
                var n = Math.round(expterm)-1;
              } else {
                var n = Math.round(expterm);
              }
              var m = (num / Math.pow(10,(n))).toFixed(1);
              if ( num < 0.001) {
                $('#'+ table +' tr:nth-child('+i+')>td:nth-child(11)')[0].innerHTML = m.toString() +'&sdot;10<sup>'+n.toString()+'</sup> '+ unit ;
              } else if (num < 1000){
                $('#'+ table +' tr:nth-child('+i+')>td:nth-child(11)')[0].innerHTML = num.toString() +' '+ unit;
              } else {
                $('#'+ table +' tr:nth-child('+i+')>td:nth-child(11)')[0].innerHTML = m.toString() +'&sdot;10<sup>'+n.toString()+'</sup> '+ unit ;
             };
      };

function numtoscientificKd(kd, error, unit){
          var expterm = Math.log10(kd);
          var decimalPart = expterm - Math.floor(expterm);

          if (decimalPart > 0.5) {
            var n = Math.round(expterm)-1;
          } else {
            var n = Math.round(expterm);
          }

  //Case one: unit = M-1
      if (unit == 'M-1') {
          if (n >= 3){
            var m = (kd / (Math.pow(10,n))).toFixed(2);
            $('#scientificKd')[0].innerHTML = '<span>' + m.toString() +'&sdot;10<sup>'+n.toString()+'</sup> </span>' ;
            if (!(error === 0)) {
              var exptermerror = Math.log10(error);
              var decimalParterror = exptermerror - Math.floor(exptermerror);

              if (decimalParterror > 0.5) {
                var nerror = Math.round(exptermerror)-1;
              } else {
                var nerror = Math.round(exptermerror);
              }
              var merror = (error / Math.pow(10,nerror)).toFixed(2);
              $('#scientificKderror')[0].innerHTML = '<span> &#177; ' + merror.toString() +'&sdot;10<sup>'+nerror.toString()+'</sup> </span>' ;
            }
            $('#scientificKdunit')[0].innerHTML = '<span> M </span>' ;

          } else if ( n >= 0 && n < 3) {
            var m = kd;
            $('#scientificKd')[0].innerHTML = '<span>' + m.toString() + '</span>' ;
            if (!(error === 0)) {
              var merror = error;
              $('#scientificKderror')[0].innerHTML = '<span>  &#177; ' + merror.toString() +'</span>' ;
            }
            $('#scientificKdunit')[0].innerHTML = '<span> M </span>' ;

         } else if ( n >= -3 && n < 0) {
            var m = (kd * Math.pow(10,3));
            m < 10 ? m = (kd * Math.pow(10,3)).toFixed(1) : m = (kd * Math.pow(10,3)).toFixed(0);
            $('#scientificKd')[0].innerHTML = '<span>' + m.toString() + '</span>' ;
            if (!(error === 0)) {
              var merror = (error * Math.pow(10,3)).toFixed(0);
              merror < 1 ? merror = (error * Math.pow(10,3)).toFixed(2) : merror = (error * Math.pow(10,3)).toFixed(0);
              $('#scientificKderror')[0].innerHTML = '<span> &#177; ' + merror.toString() +' </span>' ;
            }
            $('#scientificKdunit')[0].innerHTML = '<span> mM </span>' ;

          } else if ( n >= -6 && n < -3) {
            var m = (kd * Math.pow(10,6)).toFixed(0);
            m < 10 ? m = (kd * Math.pow(10,6)).toFixed(1) : m = (kd * Math.pow(10,6)).toFixed(0);
            $('#scientificKd')[0].innerHTML = '<span>' + m.toString() + '</span>' ;
            if (!(error === 0)) {
              var merror = (error * Math.pow(10,6));
              merror < 1 ? merror = (error * Math.pow(10,6)).toFixed(2) : merror = (error * Math.pow(10,6)).toFixed(0);
              $('#scientificKderror')[0].innerHTML = '<span> &#177; ' + merror.toString() +' </span>' ;
            }
            $('#scientificKdunit')[0].innerHTML = '<span> &micro;M </span>' ;

          } else if ( n >= -9 && n < -6) {
            var m = (kd * Math.pow(10,9)).toFixed(0);
            m < 10 ? m = (kd * Math.pow(10,9)).toFixed(1) : m = (kd * Math.pow(10,9)).toFixed(0);
            $('#scientificKd')[0].innerHTML = '<span>' + m.toString() + '</span>' ;
            if (!(error === 0)) {
              var merror = (error * Math.pow(10,9)).toFixed(0);
              merror < 1 ? merror = (error * Math.pow(10,9)).toFixed(2) : merror = (error * Math.pow(10,9)).toFixed(0);
              $('#scientificKderror')[0].innerHTML = '<span> &#177; ' + merror.toString() +' </span>' ;
            }
            $('#scientificKdunit')[0].innerHTML = '<span> nM </span>' ;

          } else if ( n >= -12 && n < -9) {
            var m = (kd * Math.pow(10,12)).toFixed(0);
            m < 10 ? m = (kd * Math.pow(10,12)).toFixed(1) : m = (kd * Math.pow(10,12)).toFixed(0);
            $('#scientificKd')[0].innerHTML = '<span>' + m.toString() + '</span>' ;
            if (!(error === 0)) {
              var merror = (error * Math.pow(10,12)).toFixed(0);
              merror < 1 ? merror = (error * Math.pow(10,12)).toFixed(2) : merror = (error * Math.pow(10,12)).toFixed(0);
              $('#scientificKderror')[0].innerHTML = '<span> &#177; ' + merror.toString() +' </span>' ;
            }
            $('#scientificKdunit')[0].innerHTML = '<span> pM </span>' ;

          } else {
            var nadapted = n+12
            var m = (kd / (Math.pow(10,n)) ).toFixed(2);
            $('#scientificKd')[0].innerHTML = '<span>' + m.toString() +'&sdot;10<sup>'+nadapted.toString()+'</sup> </span>' ;
            if (!(error === 0)) {
              var merror = (error / (Math.pow(10,n))).toFixed(2);
              $('#scientificKderror')[0].innerHTML = '<span> &#177; ' + merror.toString() +'&sdot;10<sup>'+nadapted.toString()+'</sup> </span>' ;
            }
            $('#scientificKdunit')[0].innerHTML = '<span> pM </span>' ;
          };
  //Case two: unit = M-2
    } else if (unit == 'M-2') {
      if (n >= 3){
        var m = (kd / (Math.pow(10,n))).toFixed(2);
        $('#scientificKd')[0].innerHTML = '<span>' + m.toString() +'&sdot;10<sup>'+n.toString()+'</sup> </span>' ;
        if (!(error === 0)) {
          var exptermerror = Math.log10(error);
          var decimalParterror = exptermerror - Math.floor(exptermerror);

          if (decimalParterror > 0.5) {
            var nerror = Math.round(exptermerror)-1;
          } else {
            var nerror = Math.round(exptermerror);
          }
          var merror = (error / (Math.pow(10,n))).toFixed(2);
          $('#scientificKderror')[0].innerHTML = '<span> &#177; ' + merror.toString() +'&sdot;10<sup>'+nerror.toString()+'</sup> </span>' ;
        }
        $('#scientificKdunit')[0].innerHTML = '<span> M<sup>2</sup></span>' ;

      } else if ( n >= 0 && n < 3) {
        var m = kd;
        $('#scientificKd')[0].innerHTML = '<span>' + m.toString() + '</span>' ;
        if (!(error === 0)) {
          var merror = error;
          $('#scientificKderror')[0].innerHTML = '<span>  &#177; ' + merror.toString() +'</span>' ;
        }
        $('#scientificKdunit')[0].innerHTML = '<span>  M<sup>2</sup></span>' ;

     } else if ( n >= -6 && n < 0) {
        var m = parseFloat((kd * Math.pow(10,6)).toPrecision(4));
        $('#scientificKd')[0].innerHTML = '<span>' + m.toString() + '</span>' ;
        if (!(error === 0)) {
          var merror = parseFloat((error * Math.pow(10,6)).toPrecision(3));
          $('#scientificKderror')[0].innerHTML = '<span> &#177; ' + merror.toString() +' </span>' ;
        }
        $('#scientificKdunit')[0].innerHTML = '<span> mM<sup>2</sup> </span>' ;

      } else if ( n >= -12 && n < -6) {
        var m = parseFloat((kd * Math.pow(10,12)).toPrecision(4));
        $('#scientificKd')[0].innerHTML = '<span>' + m.toString() + '</span>' ;
        if (!(error === 0)) {
          var merror = parseFloat((error * Math.pow(10,12)).toPrecision(3));
          $('#scientificKderror')[0].innerHTML = '<span> &#177; ' + merror.toString() +' </span>' ;
        }
        $('#scientificKdunit')[0].innerHTML = '<span> &micro;M<sup>2</sup> </span>' ;

      } else if ( n >= -18 && n < -12) {
        var m = parseFloat((kd * Math.pow(10,18)).toPrecision(4));
        $('#scientificKd')[0].innerHTML = '<span>' + m.toString() + '</span>' ;
        if (!(error === 0)) {
          var merror = parseFloat((error * Math.pow(10,18)).toPrecision(3));
          $('#scientificKderror')[0].innerHTML = '<span> &#177; ' + merror.toString() +' </span>' ;
        }
        $('#scientificKdunit')[0].innerHTML = '<span> nM<sup>2</sup> </span>' ;

      } else if ( n >= -24 && n < -18) {
        var m = parseFloat((kd * Math.pow(10,24)).toPrecision(4));
        $('#scientificKd')[0].innerHTML = '<span>' + m.toString() + '</span>' ;
        if (!(error === 0)) {
          var merror = parseFloat((error * Math.pow(10,24)).toPrecision(3));
          $('#scientificKderror')[0].innerHTML = '<span> &#177; ' + merror.toString() +' </span>' ;
        }
        $('#scientificKdunit')[0].innerHTML = '<span> pM<sup>2</sup> </span>' ;

      } else {
        var nadapted = n+24
        var m = (kd / (Math.pow(10,n)) ).toFixed(2);
        $('#scientificKd')[0].innerHTML = '<span>' + m.toString() +'&sdot;10<sup>'+nadapted.toString()+'</sup> </span>' ;
        if (!(error === 0)) {
          var merror = (error / (Math.pow(10,n))).toFixed(2);
          $('#scientificKderror')[0].innerHTML = '<span> &#177; ' + merror.toString() +'&sdot;10<sup>'+nadapted.toString()+'</sup> </span>' ;
        }
        $('#scientificKdunit')[0].innerHTML = '<span> pM<sup>2</sup> </span>' ;
      };
  //Case three: unit = M-3
  } else if (unit == 'M-3') {
      if (n >= 3){
        var m = (kd / (Math.pow(10,n))).toFixed(2);
        $('#scientificKd')[0].innerHTML = '<span>' + m.toString() +'&sdot;10<sup>'+n.toString()+'</sup> </span>' ;
        if (!(error === 0)) {
          var exptermerror = Math.log10(error);
          var decimalParterror = exptermerror - Math.floor(exptermerror);

          if (decimalParterror > 0.5) {
            var nerror = Math.round(exptermerror)-1;
          } else {
            var nerror = Math.round(exptermerror);
          }
          var merror = (error / (Math.pow(10,nerror))).toFixed(2);
          $('#scientificKderror')[0].innerHTML = '<span> &#177; ' + merror.toString() +'&sdot;10<sup>'+nerror.toString()+'</sup> </span>' ;
        }
        $('#scientificKdunit')[0].innerHTML = '<span> M<sup>3</sup> </span>' ;

      } else if ( n >= 0 && n < 3) {
        var m = kd;
        $('#scientificKd')[0].innerHTML = '<span>' + m.toString() + '</span>' ;
        if (!(error === 0)) {
          var merror = error;
          $('#scientificKderror')[0].innerHTML = '<span>  &#177; ' + merror.toString() +'</span>' ;
        }
        $('#scientificKdunit')[0].innerHTML = '<span> M<sup>3</sup> </span>' ;

     } else if ( n >= -9 && n < 0) {
       var m = parseFloat((kd * Math.pow(10,9)).toPrecision(4));
       $('#scientificKd')[0].innerHTML = '<span>' + m.toString() + '</span>' ;
       if (!(error === 0)) {
         var merror = parseFloat((error * Math.pow(10,9)).toPrecision(3));
         $('#scientificKderror')[0].innerHTML = '<span> &#177; ' + merror.toString() +' </span>' ;
       }
       $('#scientificKdunit')[0].innerHTML = '<span> mM<sup>3</sup> </span>' ;

      } else if ( n >= -18 && n < -9) {
        var m = parseFloat((kd * Math.pow(10,18)).toPrecision(4));
        $('#scientificKd')[0].innerHTML = '<span>' + m.toString() + '</span>' ;
        if (!(error === 0)) {
          var merror = parseFloat((error * Math.pow(10,18)).toPrecision(3));
          $('#scientificKderror')[0].innerHTML = '<span> &#177; ' + merror.toString() +' </span>' ;
        }
        $('#scientificKdunit')[0].innerHTML = '<span> &micro;M<sup>3</sup> </span>' ;

      } else if ( n >= -27 && n < -18) {
        var m = parseFloat((kd * Math.pow(10,27)).toPrecision(4));
        $('#scientificKd')[0].innerHTML = '<span>' + m.toString() + '</span>' ;
        if (!(error === 0)) {
          var merror = parseFloat((error * Math.pow(10,27)).toPrecision(3));
          $('#scientificKderror')[0].innerHTML = '<span> &#177; ' + merror.toString() +' </span>' ;
        }
        $('#scientificKdunit')[0].innerHTML = '<span> nM<sup>3</sup> </span>' ;

      } else if ( n >= -36 && n < -27) {
        var m = parseFloat((kd * Math.pow(10,36)).toPrecision(4));
        $('#scientificKd')[0].innerHTML = '<span>' + m.toString() + '</span>' ;
        if (!(error === 0)) {
          var merror = parseFloat((error * Math.pow(10,36)).toPrecision(3));
          $('#scientificKderror')[0].innerHTML = '<span> &#177; ' + merror.toString() +' </span>' ;
        }
        $('#scientificKdunit')[0].innerHTML = '<span> pM<sup>3</sup> </span>' ;

      } else {
        var nadapted = n+36
        var m = (kd / (Math.pow(10,n)) ).toFixed(2);
        $('#scientificKd')[0].innerHTML = '<span>' + m.toString() +'&sdot;10<sup>'+nadapted.toString()+'</sup> </span>' ;
        if (!(error === 0)) {
          var merror = (error / (Math.pow(10,n))).toFixed(2);
          $('#scientificKderror')[0].innerHTML = '<span> &#177; ' + merror.toString() +'&sdot;10<sup>'+nadapted.toString()+'</sup> </span>' ;
        }
        $('#scientificKdunit')[0].innerHTML = '<span> pM<sup>3</sup> </span>' ;
      };
    //case different power in unit
    } else {
        var m = (kd / (Math.pow(10,n))).toPrecision(4);
        $('#scientificKd')[0].innerHTML = '<span>' + m.toString() +'&sdot;10<sup>'+n.toString()+'</sup> </span>' ;
        if (!(error === 0)) {
          var exptermerror = Math.log10(error);
          var decimalParterror = exptermerror - Math.floor(exptermerror);

          if (decimalParterror > 0.5) {
            var nerror = Math.round(exptermerror)-1;
          } else {
            var nerror = Math.round(exptermerror);
          }
          var merror = (error / Math.pow(10,nerror)).toPrecision(3);
          $('#scientificKderror')[0].innerHTML = '<span> &#177; ' + merror.toString() +'&sdot;10<sup>'+nerror.toString()+'</sup> </span>' ;
        }
        if (unit.includes("-")) {
           var powerunit = unit.split("-").pop();
           $('#scientificKdunit')[0].innerHTML = '<span> M<sup>'+powerunit+'</sub></span>';
        } else {
          var powerunit = unit.split(M).pop();
          $('#scientificKdunit')[0].innerHTML = '<span> M<sup>'+powerunit+'</sub></span>';
        }
    };
};



  $(document).on('turbolinks:load',function(){
    $('#interaction-dblookup-form').on('ajax:complete', function(event, data, status){
      $('#dbresults').html(data.responseText);
     });
  });


  $(document).on('turbolinks:load',function(){
    $('#framework-lookup-form').on('ajax:complete', function(event, data, status){
      $('#framework_result').html(data.responseText);
     });
  });


  $(document).on('turbolinks:load',function(){
    $('#interaction-advlookup-form').on('ajax:complete', function(event, data, status){
      $('#advresults').html(data.responseText)
    })
  });


  function setAssayPanels() {
    var val = $('.assay-type:checked').val();
    var variationStart = [];
    if (typeof  $("#interaction_variation") !== 'undefined' &&  $("#interaction_variation").length > 0) {
       variationStart = $("#interaction_variation").val().split(" ");
    };
    var variationEnd = [];

    switch (val) {
      case 'Competitive Binding Assay':
        $("#indicatorpanel").show();
        $(".indicator-related").show(adjustDecimalPlacesLoad("interaction_stoichometry_indicator"));
        $("#conjugatepanel").hide();
        $(".conjugate-related").hide();
        radiobtn = document.getElementById("competive");
        radiobtn.checked=true;
        variationEnd = variationStart.filter(x => x != "conjugate");
        $("#interaction_variation").val(variationEnd.join(" "));
        $(".multiple_variation_checkbox:checkbox[value=conjugate]").prop("checked",false);
        $(".single_variation_selection:radio[value=conjugate]").prop("checked",false);
        checkInitialVariation();
        break;
      case 'Associative Binding Assay':
        $("#indicatorpanel").hide();
        $(".indicator-related").hide();
        $("#conjugatepanel").show();
        $(".conjugate-related").show(adjustDecimalPlacesLoad("interaction_stoichometry_conjugate"));
        radiobtn = document.getElementById("direct");
        radiobtn.checked=true;
        variationEnd = variationStart.filter(x => x != "indicator");
        $(".multiple_variation_checkbox:checkbox[value=indicator]").prop("checked",false);
        $(".single_variation_selection:radio[value=indicator]").prop("checked",false);
        $("#interaction_variation").val(variationEnd.join(" "));
        checkInitialVariation();
        break;
      case 'Direct Binding Assay':
        $("#indicatorpanel").hide();
        $(".indicator-related").hide();
        $("#conjugatepanel").hide();
        $(".conjugate-related").hide();
        radiobtn = document.getElementById("direct");
        radiobtn.checked=true;
        variationEnd = variationStart.filter(x => x != "conjugate");
        $(".multiple_variation_checkbox:checkbox[value=conjugate]").prop("checked",false);
        $(".single_variation_selection:radio[value=conjugate]").prop("checked",false);
        variationEnd = variationStart.filter(x => x != "indicator");
        $(".multiple_variation_checkbox:checkbox[value=indicator]").prop("checked",false);
        $(".single_variation_selection:radio[value=indicator]").prop("checked",false);
        $("#interaction_variation").val(variationEnd.join(" "));
        checkInitialVariation();
        break;
      }
  };



  $(document).on('ready turbolinks:load', function(){
      $('.solvent_system').on('change', function() {
        var val = $('.solvent_system:checked').val();
        switch (val) {
          case 'Complex Mixture':
            $("#solvColumnHeadings").show();
            $("#solvent_panel").show();
            $("#ionic_strength_panel").show();
            $(".additive-container").show();
            $("#interaction_interaction_solvents_attributes_1_first_solvent_name").show();
            $("#interaction_interaction_solvents_attributes_2_first_solvent_name").show();
            $("#interaction_interaction_solvents_attributes_0_volume_percent").show();
            $("#interaction_interaction_solvents_attributes_0_volume_percent").attr('readonly', true);
            $("#interaction_interaction_solvents_attributes_1_volume_percent").show();
            $("#interaction_interaction_solvents_attributes_2_volume_percent").show();
            // $("#complex_solvent").show();
            $("#buffer_system").hide();
            // $("#single_solvent").hide();
            return event.preventDefault();
            break;
          case 'Buffer System':
            $("#solvent_panel").hide();
            // $("#complex_solvent").hide();
            $("#buffer_system").show();
            // $("#single_solvent").hide();
            return event.preventDefault();
            break;
          case 'Single Solvent':
            $("#solvColumnHeadings").hide();
            $("#solvent_panel").show();
            $("#ionic_strength_panel").hide();
            $(".additive-container").hide();
            $("#interaction_interaction_solvents_attributes_1_first_solvent_name").hide();
            $("#interaction_interaction_solvents_attributes_2_first_solvent_name").hide();
            $("#interaction_interaction_solvents_attributes_0_volume_percent").hide();
            $("#interaction_interaction_solvents_attributes_1_volume_percent").hide();
            $("#interaction_interaction_solvents_attributes_2_volume_percent").hide();
            $("#buffer_system").hide();
            return event.preventDefault();
          case 'No Solvent':
            $("#solvent_panel").hide();
            $("#ionic_strength_panel").hide();
            $(".additive-container").hide();
            $("#interaction_interaction_solvents_attributes_1_first_solvent_name").hide();
            $("#interaction_interaction_solvents_attributes_2_first_solvent_name").hide();
            $("#interaction_interaction_solvents_attributes_0_volume_percent").hide();
            $("#interaction_interaction_solvents_attributes_1_volume_percent").hide();
            $("#interaction_interaction_solvents_attributes_2_volume_percent").hide();
            $("#buffer_system").hide();
            return event.preventDefault();
            break;
          }
      });
  });

  $(document).on('ready turbolinks:load', function(){

        var val = $('.solvent_system:checked').val();
        switch (val) {
          case 'Complex Mixture':
            $("#solvent_panel").show();
            $("#ionic_strength_panel").show();
            $(".additive-container").show();
            $("#interaction_interaction_solvents_attributes_1_first_solvent_name").show();
            $("#interaction_interaction_solvents_attributes_2_first_solvent_name").show();
            $("#interaction_interaction_solvents_attributes_0_volume_percent").show();
            $("#interaction_interaction_solvents_attributes_0_volume_percent").attr('readonly', true);
            $("#interaction_interaction_solvents_attributes_1_volume_percent").show();
            $("#interaction_interaction_solvents_attributes_2_volume_percent").show();
            // $("#complex_solvent").show();
            $("#buffer_system").hide();
            // $("#single_solvent").hide();
            return event.preventDefault();
            break;
          case 'Buffer System':
            $("#solvent_panel").hide();
            // $("#complex_solvent").hide();
            $("#buffer_system").show();
            // $("#single_solvent").hide();
            return event.preventDefault();
            break;
          case 'Single Solvent':
            $("#solvent_panel").show();
            $("#ionic_strength_panel").hide();
            $(".additive-container").hide();
            $("#interaction_interaction_solvents_attributes_1_first_solvent_name").hide();
            $("#interaction_interaction_solvents_attributes_2_first_solvent_name").hide();
            $("#interaction_interaction_solvents_attributes_0_volume_percent").hide();
            $("#interaction_interaction_solvents_attributes_1_volume_percent").hide();
            $("#interaction_interaction_solvents_attributes_2_volume_percent").hide();
            $("#buffer_system").hide();
            return event.preventDefault();
          case 'No Solvent':
            $("#solvent_panel").hide();
            $("#ionic_strength_panel").hide();
            $(".additive-container").hide();
            $("#interaction_interaction_solvents_attributes_1_first_solvent_name").hide();
            $("#interaction_interaction_solvents_attributes_2_first_solvent_name").hide();
            $("#interaction_interaction_solvents_attributes_0_volume_percent").hide();
            $("#interaction_interaction_solvents_attributes_1_volume_percent").hide();
            $("#interaction_interaction_solvents_attributes_2_volume_percent").hide();
            $("#buffer_system").hide();
            return event.preventDefault();
            break;
          }

  });


//some other stuff
  $(document).on('click', 'form .remove_fields', function(event) {
    $(this).prev('input[type=hidden]').val('1');
    $(this).closest('.form-group').hide();
    return event.preventDefault();
  });

  $(document).on('click', 'form .add_fields', function(event) {
    var regexp, time;
    time = new Date().getTime();
    regexp = new RegExp($(this).data('id'), 'g');
    $(this).before($(this).data('fields').replace(regexp, time));
    return event.preventDefault();
  });

$(document).on('ready turbolinks:load', function() {
  return $('#interaction_additive_name').autocomplete({
    source: $('#interaction_additive_name').data('autocomplete-source')
  });
});


$(document).on('ready turbolinks:load', function() {
  return $('#second_additive_name').autocomplete({
    source: $('#second_additive_name').data('autocomplete-source')
  });
});

$(document).on('ready turbolinks:load', function() {
  return $('#third_additive_name').autocomplete({
    source: $('#third_additive_name').data('autocomplete-source')
  });
});

$(document).on('ready turbolinks:load', function() {
  return $('#fourth_additive_name').autocomplete({
    source: $('#fourth_additive_name').data('autocomplete-source')
  });
});

$(document).on('ready turbolinks:load', function() {
  return $('.first_solvent_name').autocomplete({
    source: $('.first_solvent_name').data('autocomplete-source')
  });
});

$(document).on('ready turbolinks:load', function() {
  return $('#second_solvent_name').autocomplete({
    source: $('#second_solvent_name').data('autocomplete-source')
  });
});

$(document).on('ready turbolinks:load', function() {
  return $('#third_solvent_name').autocomplete({
    source: $('#third_solvent_name').data('autocomplete-source')
  });
});

$(document).on('ready turbolinks:load', function() {
  return $('#fourth_solvent_name').autocomplete({
    source: $('#fourth_solvent_name').data('autocomplete-source')
  });
});



function checkMW() {
      var mol_MW = parseFloat($("#mol_weight_molecule_hidden").val())
      var host_MW = parseFloat($("#mol_weight_host_hidden").val())
      if (mol_MW > host_MW) {
        $('#mw_info').addClass('tored')
      } else {
        $('#mw_info').removeClass('tored')
      };
    };
//nest form helpers
