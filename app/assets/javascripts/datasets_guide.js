

  function sharable_link_exp() {
    defaultPopoverBottom.title = "<strong>Sharable Link</strong>"
    defaultPopoverBottom.content = "<p>You can use this link to give an NON-editable preview of your dataset, e.g. for remote peers in your project.</p><p>On the very right, you can find a quick note in which state your dataset is.</p>";
    $("#sharable_link_show").addClass("guide-panel-active");
    $("#sharable_link_show").popover(defaultPopoverBottom).popover("show");
  }

  function doi_exp(prevision_popover) {
    $(prevision_popover).popover("destroy");
    $(prevision_popover).removeClass("guide-panel-active");
    defaultPopoverBottom.title = "<strong>DOI</strong>";
    defaultPopoverBottom.content = "<p>The Digital Object Identifier (DOI) will allow everybody to find you dataset after you have published it.</p><p>On the very right, you can find a quick note which license is applied to the dataset for reusability.</p>";
    $("#doi_show").popover(defaultPopoverBottom).popover("show");
    $("#doi_show").addClass("guide-panel-active");
  }


  function title_exp(prevision_popover, work_state) {
    $(prevision_popover).popover("destroy");
    $(prevision_popover).removeClass("guide-panel-active");
    defaultPopoverBottom.title = "<strong>Title</strong>";
    defaultPopoverBottom.content = "<p>The title of your dataset must be uniqe.</p>";
    if (work_state == "pre") {
      defaultPopoverBottom.content = "<p>The title of your dataset must be uniqe.</p>";
    } else {
      defaultPopoverBottom.content = "<p>Since you provided a literature reference SupraBank already filled this part for you with the title of the scholarly article.</p>";
    }
    $("#title_show").popover(defaultPopoverBottom).popover("show");
    $("#title_show").addClass("guide-panel-active");
  }

  function creator_exp(prevision_popover, work_state) {
    $(prevision_popover).popover("destroy");
    $(prevision_popover).removeClass("guide-panel-active");
    defaultPopoverBottom.title = "<strong>Creators</strong>";
    if (work_state == "pre") {
      defaultPopoverBottom.content = "<p>These are the people that created the data (acquisition & analysis), typically identical with the authors of the referenced literature.</p>";
    } else {
      defaultPopoverBottom.content = "<p>These are the people that created the data (acquisition & analysis), typically identical with the authors of the referenced literature.</p><p>Since you provided a literature reference SupraBank already filled this part for you.</p>";
    }
    $("#creators_show").popover(defaultPopoverBottom).popover("show");
    $("#creators_show").addClass("guide-panel-active");
  }

  function contributors_exp(prevision_popover, work_state) {
    $(prevision_popover).popover("destroy");
    $(prevision_popover).removeClass("guide-panel-active");
    defaultPopoverBottom.title = "<strong>Contributors</strong>";
    defaultPopoverBottom.content = "<p>These are the people that take care about the research data management (RDM), namely creating datasets and interations on the SupraBank.</p>";
    $("#contributors_show").popover(defaultPopoverBottom).popover("show");
    $("#contributors_show").addClass("guide-panel-active");
  }
  
  function meta_data_exp(prevision_popover, work_state) {
    $(prevision_popover).popover("destroy");
    $(prevision_popover).removeClass("guide-panel-active");
    defaultPopoverTop.title = "<strong>Edit the Dataset</strong>";
    if (work_state == "pre") {
      defaultPopoverTop.content = "<p>Click this button to edit the meta data (Title, Description, Literature Reference etc. pp) of the dataset. </p>";
    } else {
      defaultPopoverTop.content = "<p>Click this button to edit the meta data (Title, Description, Literature Reference etc. pp) of the dataset. </p><p>Since you provided a literature reference SupraBank already filled this part for you.</p>";
    }
    $("#meta_data_show").popover(defaultPopoverTop).popover("show");
    $("#meta_data_show").addClass("guide-panel-active");
  }
  