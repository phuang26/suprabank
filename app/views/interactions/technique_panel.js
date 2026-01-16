$(document).on('ready turbolinks:load', function(){
    $('.technique').on('change', function() {
      var val = $('.technique:checked').val();
      switch (val) {
        case 'Isothermal Titration Calorimetry':
          $("#technique_name u").text('Isothermal Titration Calorimetry');
          $("#technique_panel_content").html("<p> Hello </p>")
          break;
        case 'Circular Dichroism':
          $("#icdpanel").show();
          $("#itcpanel").hide();
          $("#fluorescencepanel").hide();
          $("#nmrpanel").hide();
          $("#absorbancepanel").hide();
          break;
        case 'Fluorescence':
          $("#technique_name u").text('Fluorescence');
          $("#technique_panel_content").html("<div><%= escape_javascript(render 'interactions/new/fluorescence_panel', f: f) %></div>")
          break;
        case 'Absorbance':
          $("#absorbancepanel").show();
          $("#nmrpanel").hide();
          $("#fluorescencepanel").hide();
          $("#itcpanel").hide();
          $("#icdpanel").hide();
          break;
        case 'Nuclear Magnetic Resonance':
          $("#nmrpanel").show();
          $("#fluorescencepanel").hide();
          $("#itcpanel").hide();
          $("#icdpanel").hide();
          $("#absorbancepanel").hide();
          break;
        case 'Surface Enhanced Raman Scattering':
          $("#nmrpanel").show();
          $("#fluorescencepanel").hide();
          $("#itcpanel").hide();
          $("#icdpanel").hide();
          $("#serspanel").hide();
          break;
      }
    });
});
