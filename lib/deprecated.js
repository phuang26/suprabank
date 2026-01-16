//deprecated guide based on tooltips
<!--
function stepI() {
  defaultTooltip.title = "<h5><strong>Step 1</strong> <button type='button' name='done' class='btn btn-sm btn-primary'>DONE</button></h5>  <p>Select an assay type</p>";
  $("#assay_type_label").tooltip(defaultTooltip).tooltip("show");
  $("#assay_type_panel").addClass("guide-panel-active");
}

function stepII() {
  $("#assay_type_label").tooltip("destroy");
  $("#assay_type_panel").removeClass("guide-panel-active");
  defaultTooltip.title = "<h5><strong>Step 2</strong></h5> <p>Select the technique you used for determination</p>";
  $("#technique_label").tooltip(defaultTooltip).tooltip("show");
  $("#technique_selection").addClass("guide-panel-active");
}


function stepIII() {
  $("#technique_label").tooltip("destroy");
  $("#technique_selection").removeClass("guide-panel-active");
  defaultTooltip.title = "<h5><strong>Step 3</strong></h5> <p>Assign the molecules that are involved in the interaction. Start typing the name of the molecule. SupraBank will search for the molecule you need.</p>";
  $("#binding_label").tooltip(defaultTooltip).tooltip("show");
  $("#binding_molecules_panel").addClass("guide-panel-active");
}



function stepIV() {
  $("#binding_label").tooltip("destroy");
  $("#binding_molecules_panel").removeClass("guide-panel-active");
  defaultTooltip.title = "<h5><strong>Step 4</strong></h5> <p>Please provide some details of your measurements.</p>";
  $(".technique-panel-label").tooltip(defaultTooltip).tooltip("show");
  $("#technique_panel_content").addClass("guide-panel-active");
}

function stepV() {
  $(".technique-panel-label").tooltip("destroy");
  $("#technique_panel_content").removeClass("guide-panel-active");
  defaultTooltip.title = "<h5><strong>Step 5</strong></h5> <p>Provide the binding information. Just type; SupraBank supports you with automatic calculations.</p>";
  $("#binding_properties_label").tooltip(defaultTooltip).tooltip("show");
  $("#binding_properties").addClass("guide-panel-active");
}

function stepVI() {
  $("#binding_properties_label").tooltip("destroy");
  $("#binding_properties").removeClass("guide-panel-active");
  defaultTooltip.title = "<h5><strong>Step 6</strong></h5> <p>Please provide further conditions of your experiment such as solvents.</p>";
  $("#conditions_label").tooltip(defaultTooltip).tooltip("show");
  $("#conditions_panel").addClass("guide-panel-active");
}

function stepVII() {
  $("#conditions_label").tooltip("destroy");
  $("#conditions_panel").removeClass("guide-panel-active");
  defaultTooltip.title = "<h5><strong>Step 7</strong></h5> <p>You may add specfic thermodynamic and kinetic parameters or leave a comment. Eventually click on Publishing.</p>";
  $("#options_selection").tooltip(defaultTooltip).tooltip("show");
  $("#options_selection").addClass("guide-panel-active");
}

function stepVIII() {
  $("#options_selection").tooltip("destroy");
  $("#options_selection").removeClass("guide-panel-active");
  defaultTooltip.title = "<h5><strong>Final step</strong></h5> <p>You are almost done, great! Just decide whether you want to use the entry just for youself (embargoed) or start the reviewing process. Finally click on Create Interaction</p>";
  $("#int_publishing_panel").tooltip(defaultTooltip).tooltip("show");
  $("#int_publishing_panel").addClass("guide-panel-active");
}















-->
