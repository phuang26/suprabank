
function setConcentrationVariation() {
  variation = determineITCVariation();

  $("#interaction_variation").val(variation.join(" "));
  //first case for warning to user: all substances are set  to be in the cell.
  if (variation.length === 0) {
    $('#allCell').popover({
        container: 'body',
        placement : 'top',
        html : true,
    }).popover('show');
  } else {
    $('#allCell').popover({
        container: 'body',
        placement : 'top',
        html : true,
    }).popover('hide');
  };
  //second case for warning to user: all substances are set to be in the syringe.
  if (variation.length === 2 && ($('.assay-type:checked').val() === 'Direct Binding Assay')) {
    $('#allSyringe').popover({
        container: 'body',
        placement : 'top',
        html : true,
    }).popover('show');
  } else if (variation.length === 3 ) {
    $('#allSyringe').popover({
        container: 'body',
        placement : 'top',
        html : true,
    }).popover('show');
  } else {
    $('#allSyringe').popover({
        container: 'body',
        placement : 'top',
        html : true,
    }).popover('hide');
  };
};

function determineITCVariation() {
  var full = ["molecule", "host", "indicator", "conjugate"];
  var cell = $(".itc_radio:checked").map(function() {
    if (convertStringToBoolean($(this).val())) {
      return $(this).data("species");
    };
  }).get();
  let syringe = full.filter(x => !cell.includes(x));
  return syringe;
};



function itcConcentrations() {
  $(".itc_radio").each(function() {
    $(this).change(function() {
      setConcentrationVariation();
      checkInitialVariation();
    });
  });
};

function setITCVariation() {
  let syringe = $("#interaction_variation").val().split(" ");

  let full = ["molecule", "host", "indicator", "conjugate"];
  let cell = full.filter(x => !syringe.includes(x));
  syringe.forEach(function(value) {
    $(".itc_radio:radio[data-species="+value+"][value=false]").prop("checked",true);
  })
  cell.forEach(function(value) {
    $(".itc_radio:radio[data-species="+value+"][value=true]").prop("checked",true);
  })
};

function singleVariation(value="molecule") {
    $("#interaction_variation").val(value);
  $("#"+value+"_varied").show();
  $("#"+value+"_fixed").show();
  $("#"+value+"_fixed").removeClass("col-md-4");
  $("#"+value+"_fixed").addClass("col-md-2");
  var hideList = ["molecule", "host", "indicator", "conjugate"];
  hideList.splice(hideList.indexOf(value), 1);
  hideList.forEach(function(value) {
    $("#"+value+"_fixed").show();
    $("#"+value+"_varied").hide();
    $("#"+value+"_fixed").removeClass("col-md-2");
    $("#"+value+"_fixed").addClass("col-md-4");
  })
  if ($('.in_technique:checked').val() === 'IsothermalTitrationCalorimetry' ){
      calculateConcFromITC("all");
  };
  setITCVariation();
};

function multipleVariation(variation) {
  $("#interaction_variation").val(variation.join(" "));
  var hideList = ["molecule", "host", "indicator", "conjugate"];

  variation.forEach(function(value) {
    hideList.splice(hideList.indexOf(value), 1);
    $(".multiple_variation_checkbox:checkbox[value="+value+"]").prop("checked",true);
    if ($('.in_technique:checked').val() === 'IsothermalTitrationCalorimetry' ){
        calculateConcFromITC("all");
    };
    $("#"+value+"_varied").show();
    $("#"+value+"_fixed").show();
    $("#"+value+"_fixed").removeClass("col-md-4");
    $("#"+value+"_fixed").addClass("col-md-2");
  });

  hideList.forEach(function(value) {
    $(".multiple_variation_checkbox:checkbox[value="+value+"]").prop("checked",false);
    if ($('.in_technique:checked').val() === 'IsothermalTitrationCalorimetry' ){
        calculateConcFromITC("all");
    };
    $("#"+value+"_fixed").show();
    $("#"+value+"_varied").hide();
    $("#"+value+"_fixed").removeClass("col-md-2");
    $("#"+value+"_fixed").addClass("col-md-4");
  });
  setITCVariation();
};


function transferToMultiple() {
  var variation = $("#interaction_variation").val().split(" ");
  multipleVariation(variation);
  $(":radio[name=single_variation_selection]").prop("checked", false);
  $(".multiple_variation_checkbox_label").show();
  $(".single_variation_selection_label").hide();
};

function transferToSingle() {
  var variation = $("#interaction_variation").val().split(" ");
  var vari = variation[0] || "molecule";
  $("#multiple_variation").prop("checked",false);
  $(".single_variation_selection:radio[value="+vari+"]").prop("checked",true);
  singleVariation(vari);
  $(":checkbox[name=multiple_variation_selection]").prop("checked", false);
  $(".multiple_variation_checkbox_label").hide();
  $(".single_variation_selection_label").show();

  if ((variation[0]==="") && ($('.in_technique:checked').val() === 'IsothermalTitrationCalorimetry') ){
      calculateConcFromITC("molecule");
  };
};


function checkInitialVariation() {
  var variation = $("#interaction_variation").val().split(" ");

  if (variation.length > 1) {
    $("#multiple_variation").prop("checked", true);

    transferToMultiple();
  } else {
    $(":checkbox[name=multiple_variation_selection]").prop("checked", false);
    transferToSingle();
  };
};
