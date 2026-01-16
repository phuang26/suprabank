//vol%

function unwrapErrors(selector) {
  if ($(selector).parent().is(".field_with_errors")) {
    $(selector).unwrap()
  }
}


function calcsingleNMRValue(value, calc_value) {

  var entered_value = parseFloat($('#in_technique_'+value).val());

  if (!isFinite(entered_value)) {
    $('#in_technique_'+value).val(calc_value.toFixed(2));
    if (!$('#in_technique_'+value).hasClass(".calculatedITC")) {$('#in_technique_'+value).addClass(".calculatedITC"); };
    if ($("#in_technique_"+value).hasClass('.inconsistentValues')) {
        console.log(value, calc_value, "1a");
        $("#in_technique_"+value).removeClass("errorbox");
        $("#in_technique_"+value).closest(".form-group").next().remove();
        $("#in_technique_"+value).removeClass(".inconsistentValues");
      };
  } else if (isFinite(entered_value) && $('#in_technique_'+value).hasClass(".calculatedITC")) {
    $('#in_technique_'+value).val(calc_value.toFixed(2));
    if ($("#in_technique_"+value).hasClass('.inconsistentValues')) {
        console.log(value, calc_value, "2a");
        $("#in_technique_"+value).removeClass("errorbox");
        $("#in_technique_"+value).closest(".form-group").next().remove();
        $("#in_technique_"+value).removeClass(".inconsistentValues");
      };
  } else if ( isFinite(entered_value) && !$('#in_technique_'+value).hasClass(".calculatedITC")) {
    if ( entered_value === calc_value) {
      if ($("#in_technique_"+value).hasClass('.inconsistentValues')) {
          $("#in_technique_"+value).removeClass("errorbox");
          $("#in_technique_"+value).closest(".form-group").next().remove();
          $("#in_technique_"+value).removeClass(".inconsistentValues");
        };
    } else {
      if (!$("#in_technique_"+value).hasClass('.inconsistentValues')) {
         $("#in_technique_"+value).addClass("errorbox");
         $("#in_technique_"+value).closest(".form-group").after('<div class="form-group"> <div class="col-md-10 col-md-offset-2 checkzero"><p> The values are inconsistent. Please check again. If the value shall be calculated automatically, just delete the concentration value here.</p></div></div>');
         $("#in_technique_"+value).addClass(".inconsistentValues");
           }
   };
 };

};

function deletesingleNMRValue(value) {
  if( $("#in_technique_"+value).hasClass(".calculatedITC") ) {$("#in_technique_"+value).val("")};
  if ($("#in_technique_"+value).hasClass('.inconsistentValues')) {
      $("#in_technique_"+value).removeClass("errorbox");
      $("#in_technique_"+value).closest(".form-group").next().remove();
      $("#in_technique_"+value).removeClass(".inconsistentValues");
    };

};



function calcNMRValues(){

  //get values
    var  shift_unbound = parseFloat($("#in_technique_shift_unbound").val())
    var  shift_bound = parseFloat($("#in_technique_shift_bound").val());
    var delta_shift = parseFloat($('#in_technique_delta_shift').val());
    var free_to_bound = parseFloat($('#in_technique_free_to_bound').val());
    var calc_value = null


  //two values need to be given to calculate the other two

   if ( isFinite(shift_unbound) && !$('#in_technique_shift_unbound').hasClass(".calculatedITC") && isFinite(shift_bound)  && !$('#in_technique_shift_bound').hasClass(".calculatedITC")) {
      calc_value = Math.abs(shift_unbound - shift_bound);
      calcsingleNMRValue('delta_shift', calc_value)
      if (shift_unbound !== 0) {
        calc_value = shift_bound/shift_unbound;
        calcsingleNMRValue('free_to_bound', calc_value)
      } else {
        $('#in_technique_free_to_bound').val("");
      };
   } else if ( isFinite(delta_shift) || isFinite(free_to_bound) ) {
       if ( !isFinite(shift_unbound) || !isFinite(shift_bound) ) {
         deletesingleNMRValue('delta_shift');
         deletesingleNMRValue('free_to_bound');
       };
   };
 };


function calculatevolume() {
  var vol1 = parseFloat(document.getElementById('interaction_interaction_solvents_attributes_1_volume_percent').value)
  var vol2 = parseFloat(document.getElementById('interaction_interaction_solvents_attributes_2_volume_percent').value)

  if (isNaN(vol1)) {
    var vol1 = 0;
  }

  if (isNaN(vol2)) {
    var vol2 = 0;
  }

  result = 100 - (vol1 + vol2);
  document.getElementById('interaction_interaction_solvents_attributes_0_volume_percent').value = result;
  if (result < 0) {
    document.getElementById('interaction_interaction_solvents_attributes_0_volume_percent').classList.add('negative_value');
  } else {
    document.getElementById('interaction_interaction_solvents_attributes_0_volume_percent').classList.remove('negative_value');
  };
};

function checkSolventSystem(solventSystem) {
  if (solventSystem == "Single Solvent") {
    $("#interaction_interaction_solvents_attributes_0_volume_percent").val(100);
    $("#interaction_interaction_solvents_attributes_1_volume_percent").val('');
    $("#interaction_interaction_solvents_attributes_1_first_solvent_name").val('');
    $("#interaction_interaction_solvents_attributes_2_volume_percent").val('');
    $("#interaction_interaction_solvents_attributes_2_first_solvent_name").val('');
  }
};

function submissionSolventCheck() {
  $(".select_button_submit[type='submit']").click( function(){
    var solventSystem = $(".solvent_system[type='radio']:checked").val();
    checkSolventSystem(solventSystem);
  });
};

function noSolventSelection() {
  var v1 = $("#interaction_solvent_system_single_solvent").prop('checked');
  var v2 = $("#interaction_solvent_system_complex_mixture").prop('checked');
  var v3 = $("#interaction_solvent_system_buffer_system").prop('checked');
  var vall = false;
  if (!(v1 || v2 || v3 )) {
    vall = true;
  };
  if (vall) {
    $("#interaction_solvent_system_no_solvent").prop('checked', true)
  };
};

function removeCalcClass() {
  !$("#ionic_strength").hasClass('.calculatedIS') || $("#ionic_strength").removeClass('.calculatedIS');
};



function addPanelToggles() {
  $('#kinetics_toggle').click(function() {
    $('#int_kinetics_panel').collapse("toggle")
  });
  $('.thermodynamics_toggle').click(function() {
    $('#int_thermodynamics_panel').collapse("toggle")
  });
  $('#publishing_toggle').click(function() {
    $('#int_publishing_panel').collapse("toggle")
    $('#int_publishing_button').collapse("toggle")
  });
  $('#comment_toggle').click(function() {
    $('#int_comment_panel').collapse("toggle")
  });
  $('#submission_toggle').click(function() {
    $('#int_submission_panel').collapse("toggle")
  });
};

function bindingPanel() {
  if ($("input:radio[name='interaction[assay_type]']").is(":checked")) {
    $("#int_binding_panel").show(200);
    $("#interaction_stoichometry_molecule").load(adjustDecimalPlacesLoad("interaction_stoichometry_molecule"));
    $("#interaction_stoichometry_host").load(adjustDecimalPlacesLoad("interaction_stoichometry_host"));
  } else {
    $(".assay-type").click(function() {
      $("#int_binding_panel").show(200);
      $("#interaction_stoichometry_molecule").load(adjustDecimalPlacesLoad("interaction_stoichometry_molecule"));
      $("#interaction_stoichometry_host").load(adjustDecimalPlacesLoad("interaction_stoichometry_host"));
    });
  };
};


const convertStringToBoolean = (word) =>{
    switch(word.toLowerCase().trim()){
        case "yes": case "true": case "1": return true;
        case "no": case "false": case "0": case null: return false;
        default: return Boolean(word);
    }
}

function adjustDecimalPlaces(idofnum) {
  var num = parseFloat(idofnum.value);
  if (isFinite(num)) {
    if ((num % 1) > 0){
      idofnum.value=num.toFixed(2);
    } else {
      idofnum.value=Math.floor(num);
    };
  };
};

function adjustDecimalPlacesLoad(idName) {
  var num = parseFloat($("#"+idName)[0].value);
  if (isFinite(num)) {
    if ((num % 1) > 0){
      $("#"+idName)[0].value=num.toFixed(2);
    } else {
      $("#"+idName)[0].value=Math.floor(num);
    };
  };
};
