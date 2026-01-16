
function updateInteractionDOIs(dataset_id) {
  $.ajax({
    type: "PUT",
    url: "/datasets/update_dataset_interactions_dois?dataset_id=" + dataset_id,
    success: function (data) {
      return false;
    },
    error: function (data) {
      return false;
    }
  });
};



function copyToClipboard(element) {
  var $temp = $("<input>");
  $("body").append($temp);
  $temp.val($(element).text()).select();
  document.execCommand("copy");
  $temp.remove();
  $(element).tooltip('destroy')
  $(element).attr("data-original-title", "Copied!")
  $(element).tooltip("show")
}

function requestDOI(doi) {
  $.ajax({
    type: "GET",
    url: "/datasets/citation_query?term=" + encodeURIComponent(doi),
    statusCode: {
        500: function() {
          $('#info_text').html("Sorry, but we couldn't find anything for the inserted DOI. Please verify here: <a href=https://www.doi.org/ target=_blank rel=noopener noreferrer>https://www.doi.org/</a>")
          $('#info_text').addClass("text-danger")
          $('#info_text').removeClass("text-success text-info")
          $('input[name="commit"][value="Create Dataset"]').hide()
          $('input[name="commit"][value="Update Dataset"]').hide()
          $('#crossref_response').val(false)
        }
     },
    success: function (data) {
      //  console.log(data)  alert(data[0]);
      $("#wizard_metadata").show()
      $('#title_form').show();
      $("#dataset_title").val(data.title)
      if (data.abstract) {
        $("#dataset_description").val(removeTags(data.abstract))
        $('#description_form').show();
      }
      subjects = [...new Set([$('#dataset_subject_list').val() + data.subject])]
      $(".token-input-list-facebook li.token-input-token-facebook").remove()
      $('.token-input-token-facebook').remove()
      $('#dataset_subject_list').val('')
      if (data.subject) {
        $('#subject_form').show();
        $('#token-input-dataset_subject_list').val(subjects)
        $('#token-input-dataset_subject_list').select()
        $('#dataset_primary_reference').select()
      }
      if (data.author) {
        $("#dataset_creators").val(encodeURIComponent(JSON.stringify(data.author)))
      }
      $("#creation_info").show()
      $('#info_text').html("Great, we have found the resource!")
      $('#info_text').addClass("text-success")
      $('#info_text').removeClass("text-danger text-info")
      $('#crossref_response').val(true).trigger('change')
      return false;
    },
    error: function (data) {
      return false;
    }
  });
};


function removeTags(str = null) {
  if ((str === null) || (str === ''))
    return "";
  else
    str = str.toString();
  return str.replace(/(<([^>]+)>)/ig, '');
}


function rightsInformation() {
    var rights = $("#dataset_rights").val();
    switch (rights) {
      case "Creative Commons Attribution 4.0 International":
        $("#datasets_rights_information").html("&#x2022; Others may use and mix this data &#x2022; Others must cite this dataset")
        $("#datasets_rights_information").attr("href","https://creativecommons.org/licenses/by/4.0/legalcode")
        break;
      case "Creative Commons Attribution Share Alike 4.0 International":
        $("#datasets_rights_information").html("&#x2022; Others may use and mix this data &#x2022; Others must cite this dataset &#x2022; Others must must use CC-BY-SA")
        $("#datasets_rights_information").attr("href","https://creativecommons.org/licenses/by-sa/4.0/legalcode")
        break;
      case "Creative Commons Zero v1.0 Universal":
        $("#datasets_rights_information").html("&#x2022; Others may use and mix this data")
        $("#datasets_rights_information").attr("href","https://creativecommons.org/publicdomain/zero/1.0/legalcode")
        break;

    }

}

$(document).on('ready turbolinks:load', function () {
  var $loading = $('#doi_loader').hide()
  $(document).ajaxStart(function () {
    $loading.show();
  }).ajaxComplete(function () {
    $loading.hide();
  });
})





var defaultTooltipBottom = {
  container: "body",
  placement: "bottom",
  animation: true,
  trigger: "manual",
  html: true,
  template:'<div class="tooltip" role="tooltip"><div class="tooltip-inner guide-tooltip"></div></div>',
  title: ""
}

var defaultTooltipTop = {
  container: "body",
  placement: "top",
  animation: true,
  trigger: "manual",
  html: true,
  template:'<div class="tooltip" role="tooltip"><div class="tooltip-inner guide-tooltip"></div></div>',
  title: ""
}

var defaultPopoverBottom = {
  container: "body",
  placement: "bottom",
  animation: true,
  trigger: "manual",
  html: true,
  template: '<div class="popover guide-popover" role="tooltip"><div class="arrow guide-arrow-bottom"></div><h3 class="popover-title guide-popover-title"></h3><div class="popover-content guide-popover-content"></div><button type="button" name="next" class="btn btn-sm btn-black pull-right">NEXT</button></div>',
  title: "",
  content: ""
}

var defaultPopoverTop = {
  container: "body",
  placement: "top",
  animation: true,
  trigger: "manual",
  html: true,
  template: '<div class="popover guide-popover" role="tooltip"><div class="arrow guide-arrow-top"></div><h3 class="popover-title guide-popover-title"></h3><div class="popover-content guide-popover-content"></div><button type="button" name="next" class="btn btn-sm btn-black pull-right">NEXT</button></div>',
  title: "",
  content: ""
}

var defaultPopoverTopBare = {
  container: "body",
  placement: "top",
  animation: true,
  trigger: "manual",
  html: true,
  template: '<div class="popover guide-popover" role="tooltip"><div class="arrow guide-arrow-top"></div><h3 class="popover-title guide-popover-title"></h3><div class="popover-content guide-popover-content"></div></div>',
  title: "",
  content: ""
}



function applyBackdrop(selector) {
  $('#backdrop_top').css('height', $(selector).offset().top);
  $('#backdrop_bottom').css('height', $(document).height());
  var top_position = $(selector).offset().top + $(selector).height();
  $('#backdrop_top').fadeIn(200);
  $('#backdrop_bottom').css('top', top_position);
}

function applyInteractionsBackdrop(selector) {
  $('#backdrop_interactions_top').css('height', $(selector).offset().top);
  $('#backdrop_interactions_bottom').css('height', $(document).height());
  var top_position = $(selector).offset().top + $(selector).height();
  $('#backdrop_interactions_top').fadeIn(200);
  $('#backdrop_interactions_bottom').css('top', top_position);
}

function applyPublishingBackdrop(selector) {
  $('#backdrop_publishing_top').css('height', $(selector).offset().top);
  $('#backdrop_publishing_bottom').css('height', $(document).height());
  var top_position = $(selector).offset().top + $(selector).height();
  $('#backdrop_publishing_top').fadeIn(200);
  $('#backdrop_publishing_bottom').css('top', top_position);
}



