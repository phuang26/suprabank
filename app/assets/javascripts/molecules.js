$(document).on('turbolinks:load', function () {
  $('#molecule-dblookup-form').on('ajax:complete', function (event, data, status) {
    $('#molecule-dbresults').html(data.responseText)
  })
})


$(document).on('turbolinks:load', function () {
  $('#molecule-editorlookup-form').on('ajax:complete', function (event, data, status) {
    $('#molecule-editorresults').html(data.responseText)
  })
})

$(document).on('turbolinks:load', function () {
  $('#molecule-pglookup-form').on('ajax:complete', function (event, data, status) {
    $('#pgresults').html(data.responseText)
  })
})

$(document).on('turbolinks:load', function () {
  $('#molecule-lookup-form').on('ajax:complete', function (event, data, status) {
    $('#molecule-results').html(data.responseText)
  })
})

$(document).on('turbolinks:load', function () {
  $('#cidmolecule-lookup-form').on('ajax:complete', function (event, data, status) {
    $('#cidresults').html(data.responseText)
  })
})

$(document).on('turbolinks:load', function () {
  $('.assay-type').on('change', function () { })
})

$(document).on('turbolinks:load', function () {
  if (!$("#search_tag_tokens").hasClass(".tagFieldshown")) {
    $("#search_tag_tokens").tokenInput("/molecules/query_tags.json", {
      theme: "facebook",
      tokenValue: "name",
      placeholder: 'Enter tags as e.g. dye, hormone, macrocycle',
      hintText: 'Start typing and choose one or more of the proposals',
      prePopulate: $('#tag_tokens').data('load')
    });
    $("#search_tag_tokens").addClass(".tagFieldshown");
  }
  else {
    $("#search_tag_div").empty();
    $("#search_tag_div").append("<div class='col-md-8'><input type='text' name='tags_param' id='search_tag_tokens' autofocus='autofocus' class='.tagFieldshown' style='display: none;'></div>");
    $("#search_tag_tokens").tokenInput("/molecules/query_tags.json", {
      theme: "facebook",
      tokenValue: "name",
      placeholder: 'Enter tags as e.g. dye, hormone, macrocycle',
      hintText: 'Start typing and choose one or more of the proposals',
      prePopulate: $('#tag_tokens').data('load')
    });
  }
});



$(document).ajaxComplete(function () {
  $('#cid-button').click(function () {
    $("#cidsearch").show();
    return event.preventDefault();
  });
});

$(document).ajaxComplete(function () {
  $('#name-button').click(function () {
    $("#content").show();
    $("#cidsearch").hide();
    return event.preventDefault();
  });
});



$(document).ajaxComplete(function () {
  $('#loader').hide();
  $('#cidloader').hide();
  $('#turboloader').hide();
});


$(document).on('ready turbolinks:load', function () {
  $('#turboloader').hide();
});

function showLoader(whatsearch) {
  if (whatsearch === "turbo") {
    $(document)
      .ajaxStart(function () {
        $('#turboloader').show();
        $('#loader').hide();
        $('#cidloader').hide();
      })
      .ajaxComplete(function () {
        $('#turboloader').hide();
      });
  } else if (whatsearch === "pubchem") {
    $(document)
      .ajaxStart(function () {
        $('#loader').show();
        $('#turboloader').hide();
        $('#cidloader').hide()
      })
      .ajaxComplete(function () {
        $('#loader').hide();
      });
  } else if (whatsearch === "cid") {
    $(document)
      .ajaxStart(function () {
        $('#cidloader').show();
        $('#turboloader').hide();
        $('#loader').hide()
      })
      .ajaxComplete(function () {
        $('#cidloader').hide();
      });
  }
};



$(document).on('ready turbolinks:load', function () {
  $(".ui-menu-item").on({
    click: function () {
      $(this).toggleClass("active");
    }, mouseenter: function () {
      $(this).addClass("inside");
    }, mouseleave: function () {
      $(this).removeClass("inside");
    }
  });
});


$(document).ajaxComplete(function () {
  $('#mol-index').css('min-height', '200px');
  $('#mol-index').prev('div.col-sm-12').css('min-height', '300px');

});


$(document).on('turbolinks:load', function () {
  $('#molecule-dblookup-form').on('ajax:complete', function (event, data, status) {
    $('#mol-index').css('min-height', '500px');
    $('#mol-index').prev().css('min-height', '300px');
  })
})


function readURL(input) {

  if (input.files && input.files[0]) {
    var reader = new FileReader();

    reader.onload = function (e) {
      $('#instant_image').attr('src', e.target.result);
    }

    reader.readAsDataURL(input.files[0]);
  };
};

function previewFramework(id){
  $.ajax({
  type: "GET",
  url: "/frameworks/" + id + "/preview",
  success: function(data) {
  //  console.log(data)
  //  alert(data[0]);
    if (data) {
      console.log(data);
    }
    return false;
  },
  error: function(data) {
    return false;
  }
    });
};



function requestPDB(pdb_id){
  $.ajax({
  type: "GET",
  url: "/molecules/pdb_id_request?pdb_id=" + pdb_id,
  success: function(data) {
  //  console.log(data)
  //  alert(data[0]);
    if (data) {
      console.log(data);
      $('#pdbresults').html(data);
    }
    return false;
  },
  error: function(data) {
    return false;
  }
    });
};


function requestSMILES(smiles){
  $.ajax({
  type: "GET",
  url: "/molecules/smilesquery?term=" + smiles,
  success: function(data) {
  //  console.log(data)
  //  alert(data[0]);
    if (data.length > 0) {
      console.log(data)
      $("#results_table_body").empty()
      for (var entry of data) {
        $("#results_table_body").append("<tr><td> <a href=/molecules/" + entry[4] + ">" + entry[4] + "</td><td> <a href=/molecules/" + entry[4] + ">" + entry[0] + "</a></td><td class='smiles-query-td-smiles'>" + entry[5] + "</td><td>" + entry[3] + "</td></tr>")
      };
    }
    return false;
  },
  error: function(data) {
    return false;
  }
    });
};