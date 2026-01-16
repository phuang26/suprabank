    var caselist = [];

    function itcAssayType() {
      var val = $('.assay-type:checked').val();
      if ($('.in_technique:checked').val() === 'IsothermalTitrationCalorimetry'){
       switch (val) {
        case 'Competitive Binding Assay':
          $("#itc_cofactor").hide();
          $("#itc_indicator").show();
          break;
        case 'Associative Binding Assay':
          $("#itc_cofactor").show();
          $("#itc_indicator").hide();
          break;
        case 'Direct Binding Assay':
          $("#itc_cofactor").hide();
          $("#itc_indicator").hide();
          break;
        }
      }
    };


    function checkInstrumentStandard(){
         if ($("#in_technique_cell_volume").hasClass(".instrumentStandard") && !$("#in_technique_cell_volume").hasClass(".unvalidNum")) {
            $("#in_technique_cell_volume").closest(".form-group").after('<div class="form-group"> <div class="col-md-10 col-md-offset-2 "><p> This is not the standard setting for this instrument. To reset, please select the instrument again.</p></div></div>');
            $("#in_technique_cell_volume").addClass(".unvalidNum");
         };
   };

   function removeCalculatedClassITC(idofnum){
        !$(idofnum).hasClass('.calculatedITC') || $(idofnum).removeClass('.calculatedITC');
        $(idofnum).hasClass('.enteredITC') || $(idofnum).addClass('.enteredITC');
   };

   function calculateConcFromITC(whatcase){
     if ($('.in_technique:checked').val() === 'IsothermalTitrationCalorimetry'){

        if ($( "#in_technique_itc_instrument" ).val() === "") {
           if ($("#in_technique_cell_volume").hasClass(".unvalidNum")) {

             $("#in_technique_cell_volume").closest(".form-group").next().remove();
             $("#in_technique_cell_volume").removeClass(".unvalidNum");
           };
         };

       //make list of concentrations that have to be calculated or checked for consistency
       if ( whatcase === 'all') {
         caselist = ['molecule','host','indicator','conjugate'];
       } else {
         caselist = [whatcase];
       };

       //loop over all concentrations concerned
       $.each(caselist, function(index,value){

         //two possibilities: cell: where = true or syringe: where = false
         var where = $("#in_technique_"+ value +"_cell_true."+ value +"_cell").is(':checked');

         //concentrations
         var conc_itc = $("#in_technique_concentration_"+ value);
         var val_conc_itc = parseFloat($("#in_technique_concentration_"+ value).val());
         var conc_direct_low = "#interaction_lower_"+ value +"_concentration";
         var val_conc_direct_low = parseFloat($("#interaction_lower_"+ value +"_concentration").val());
         var conc_direct_up = $("#interaction_upper_"+ value +"_concentration");
         var val_conc_direct_up = parseFloat($("#interaction_upper_"+ value +"_concentration").val());

         if (where) {
         // substance is in the cell, concentration is considered to be constant (further comment use "molecule" buf of course also host, conjugate, indicator is meant)
           //case A: user didn't enter a molecule concentration directly in the molecule_panel
           if ( !isFinite(val_conc_direct_low) ||  $(conc_direct_low).hasClass('.calculatedITC')) {
             $(conc_direct_low).hasClass('.calculatedITC') || $(conc_direct_low).addClass('.calculatedITC');
             if ($(conc_direct_low).hasClass('.inconsistentConcentration')) {
                $(conc_direct_low).removeClass("errorbox");
                $(conc_direct_low).closest(".form-group").next().remove();
                $(conc_direct_low).removeClass(".inconsistentConcentration");
             };
             if ( isFinite(val_conc_itc)) { $(conc_direct_low).val(val_conc_itc);};
             //reset upper_concentration if radio_button was changed from syringe to cell
             if (isFinite(val_conc_direct_up) ) { $(conc_direct_up).val(""); };
           //case B: user entered a molecule concentration directly in the molecule_panel and it is not consistent to the ITC based one
          } else if ( $(location).attr("href").includes("edit") && !$(conc_direct_low).hasClass('.enteredITC')) {
             $(conc_direct_low).hasClass('.calculatedITC') || $(conc_direct_low).addClass('.calculatedITC');
             if ($(conc_direct_low).hasClass('.inconsistentConcentration')) {
                $(conc_direct_low).removeClass("errorbox");
                $(conc_direct_low).closest(".form-group").next().remove();
                $(conc_direct_low).removeClass(".inconsistentConcentration");
             };
             if ( isFinite(val_conc_itc)) { $(conc_direct_low).val(val_conc_itc);};
             //reset upper_concentration if radio_button was changed from syringe to cell
             if (isFinite(val_conc_direct_up) ) { $(conc_direct_up).val(""); };
           //case B: user entered a molecule concentration directly in the molecule_panel and it is not consistent to the ITC based one
           } else if (val_conc_itc !== val_conc_direct_low && isFinite(val_conc_direct_low) && isFinite(val_conc_itc)) {
             if (!$(conc_direct_low).hasClass('.inconsistentConcentration')) {
                $(conc_direct_low).addClass("errorbox");
                $(conc_direct_low).closest(".form-group").after('<div class="form-group"> <div class="col-md-10 col-md-offset-2 checkzero"><p> The concentration here is inconsistent to the one based on the ITC parameters. Please check again. If the concentration shall be calculated from the ITC parameters, just delete the concentration value here.</p></div></div>');
                $(conc_direct_low).addClass(".inconsistentConcentration");
             };
           //case C: user entered a molecule concentration directly in the molecule_panel and it is consistent to the ITC based one
           } else  if (val_conc_itc == val_conc_direct_low){
             if ($(conc_direct_low).hasClass('.inconsistentConcentration')) {
                $(conc_direct_low).removeClass("errorbox");
                $(conc_direct_low).closest(".form-group").next().remove();
                $(conc_direct_low).removeClass(".inconsistentConcentration");
             };
           } else  if (!isFinite(val_conc_itc)){
             if ($(conc_direct_low).hasClass('.inconsistentConcentration')) {
                $(conc_direct_low).removeClass("errorbox");
                $(conc_direct_low).closest(".form-group").next().remove();
                $(conc_direct_low).removeClass(".inconsistentConcentration");
             };
           };

         } else {
        // substance is in the syringe, concentration is varied
          //check if the added volume (from the syringe) is given or calculable
          var n_inj = parseFloat($("#in_technique_injection_number").val());
          var v_inj = parseFloat($("#in_technique_injection_volume").val());
          var v_init = parseFloat($("#in_technique_initial_injection_volume").val());
          var v_added = -1;
          if ( isFinite(n_inj) && isFinite(v_inj)) {
            if (!isFinite(v_init)) { v_init = v_inj };
            //asked Laura if initial injection is counted within the injection number ->  yes
            v_added = (n_inj - 1) *v_inj + v_init;
            if (isFinite(parseFloat($("#in_technique_syringe_volume").val()))) {
              if ( parseFloat($("#in_technique_syringe_volume").val()) < v_added ) {
                v_added = parseFloat($("#in_technique_syringe_volume").val());
                if (!$("#in_technique_syringe_volume").hasClass('.toolargeVolume') ) {
                   $("#in_technique_syringe_volume").closest(".form-group").after('<div class="form-group toolargeVolumeError"> <div class="col-md-10 col-md-offset-2 checkzero"><p> The volume added is larger than the volume in the syringe. Please check.</p></div></div>');
                   $("#in_technique_syringe_volume").addClass(".toolargeVolume");
                };
              } else {
                if ($("#in_technique_syringe_volume").hasClass('.toolargeVolume') ) {
                   $(".toolargeVolumeError").remove();
                   $("#in_technique_syringe_volume").removeClass(".toolargeVolume");
                 };
              };
            } else {
              if ($("#in_technique_syringe_volume").hasClass('.toolargeVolume') ) {
                 $(".toolargeVolumeError").remove();
                 $("#in_technique_syringe_volume").removeClass(".toolargeVolume");
               };
            };
          } else if (isFinite(parseFloat($("#in_technique_syringe_volume").val()))) {
            v_added = parseFloat($("#in_technique_syringe_volume").val());
            if ($("#in_technique_syringe_volume").hasClass('.toolargeVolume') ) {
               $(".toolargeVolumeError").remove();
               $("#in_technique_syringe_volume").removeClass(".toolargeVolume");
             };
          };

         //start calculation if v_cell and v_added are given
         var v_cell = parseFloat($("#in_technique_cell_volume").val());
         var conc_calc = 0;

         if ( isFinite(v_cell) && (v_added > 0) ) {
           //1. lower concentration:

           //case A: user didn't enter a molecule concentration directly in the molecule_panel
           if ( !isFinite(val_conc_direct_low) ||  $(conc_direct_low).hasClass('.calculatedITC') ) {
             $(conc_direct_low).hasClass('.calculatedITC') || $(conc_direct_low).addClass('.calculatedITC');
             if ($(conc_direct_low).hasClass('.inconsistentConcentration')) {
                $(conc_direct_low).removeClass("errorbox");
                $(conc_direct_low).closest(".form-group").next().remove();
                $(conc_direct_low).removeClass(".inconsistentConcentration");
             };
             if ( isFinite(val_conc_itc)) {$(conc_direct_low).val(conc_calc)};
           //case B: user entered a molecule concentration directly in the molecule_panel and it is not consistent to the ITC based one
         } else if (conc_calc !== val_conc_direct_low && isFinite(val_conc_direct_low) && isFinite(val_conc_itc)) {
             if (!$(conc_direct_low).hasClass('.inconsistentConcentration')) {
                $(conc_direct_low).addClass("errorbox");
                $(conc_direct_low).closest(".form-group").after('<div class="form-group"> <div class="col-md-10 col-md-offset-2 checkzero"><p> The concentration here is inconsistent to the one based on the ITC parameters. Please check again. If the concentration shall be calculated from the ITC parameters, just delete the concentration value here.</p></div></div>');
                $(conc_direct_low).addClass(".inconsistentConcentration");
             };
           //case C: user entered a molecule concentration directly in the molecule_panel and it is consistent to the ITC based one
           } else  if (conc_calc == val_conc_direct_low){
             if ($(conc_direct_low).hasClass('.inconsistentConcentration')) {
                $(conc_direct_low).removeClass("errorbox");
                $(conc_direct_low).closest(".form-group").next().remove();
                $(conc_direct_low).removeClass(".inconsistentConcentration");
             };
           } else  if (!isFinite(val_conc_itc)){
             if ($(conc_direct_low).hasClass('.inconsistentConcentration')) {
                $(conc_direct_low).removeClass("errorbox");
                $(conc_direct_low).closest(".form-group").next().remove();
                $(conc_direct_low).removeClass(".inconsistentConcentration");
             };
           };

           //2. upper concentration:
           conc_calc = val_conc_itc/ (1+ v_cell/v_added);
           //case A: user didn't enter a molecule concentration directly in the molecule_panel
           if ( !isFinite(val_conc_direct_up) ||  $(conc_direct_up).hasClass('.calculatedITC') ) {
             $(conc_direct_up).hasClass('.calculatedITC') || $(conc_direct_up).addClass('.calculatedITC');
             if ($(conc_direct_up).hasClass('.inconsistentConcentration')) {
                $(conc_direct_up).removeClass("errorbox");
                $(conc_direct_up).closest(".form-group").next().remove();
                $(conc_direct_up).removeClass(".inconsistentConcentration");
             };
              if ( isFinite(val_conc_itc)) {$(conc_direct_up).val(conc_calc.toFixed(2))};
           //case B: user entered a molecule concentration directly in the molecule_panel and it is not consistent to the ITC based one
           } else if (conc_calc !== val_conc_direct_up && isFinite(val_conc_direct_up) && isFinite(val_conc_itc)) {
             if (!$(conc_direct_up).hasClass('.inconsistentConcentration')) {
                $(conc_direct_up).addClass("errorbox");
                $(conc_direct_up).closest(".form-group").after('<div class="form-group"> <div class="col-md-10 col-md-offset-2 checkzero"><p> The concentration here is inconsistent to the one based on the ITC parameters. Please check again. If the concentration shall be calculated from the ITC parameters, just delete the concentration value here.</p></div></div>');
                $(conc_direct_up).addClass(".inconsistentConcentration");
             };
           //case C: user entered a molecule concentration directly in the molecule_panel and it is consistent to the ITC based one
           } else  if (conc_calc == val_conc_direct_up){
             if ($(conc_direct_up).hasClass('.inconsistentConcentration')) {
                $(conc_direct_up).removeClass("errorbox");
                $(conc_direct_up).closest(".form-group").next().remove();
                $(conc_direct_up).removeClass(".inconsistentConcentration");
             };
           } else  if (!isFinite(val_conc_itc)){
             if ($(conc_direct_up).hasClass('.inconsistentConcentration')) {
                $(conc_direct_up).removeClass("errorbox");
                $(conc_direct_up).closest(".form-group").next().remove();
                $(conc_direct_up).removeClass(".inconsistentConcentration");
             };
           };
        //reset lower_concentration after radio_button was changed from cell to syringe if a correct calculation is not yet possible as V_cell and V_added are missing
      } else if ( isFinite(val_conc_direct_low) ){
           //case A: user didn't enter a molecule concentration directly in the molecule_panel
           if ( $(conc_direct_low).hasClass('.calculatedITC') ) {
             $(conc_direct_low).hasClass('.calculatedITC') || $(conc_direct_low).addClass('.calculatedITC');
             if ($(conc_direct_low).hasClass('.inconsistentConcentration')) {
                $(conc_direct_low).removeClass("errorbox");
                $(conc_direct_low).closest(".form-group").next().remove();
                $(conc_direct_low).removeClass(".inconsistentConcentration");
             };
             $(conc_direct_low).val("");
           //case B: user entered a molecule concentration directly in the molecule_panel and it is not consistent to the ITC based one, condition avoids that after loading the edit formular there are everywhere inconsistent errors (as the ITC_concentrations are only know later)
         } else if (isFinite(val_conc_itc)) {
             if (!$(conc_direct_low).hasClass('.inconsistentConcentration')) {
                $(conc_direct_low).addClass("errorbox");
                $(conc_direct_low).closest(".form-group").after('<div class="form-group"> <div class="col-md-10 col-md-offset-2 checkzero"><p> The concentration here is inconsistent to the one based on the ITC parameters. Please check again. If the concentration shall be calculated from the ITC parameters, just delete the concentration value here.</p></div></div>');
                $(conc_direct_low).addClass(".inconsistentConcentration");
             };
           };
         };
         };
     });

   };
};
