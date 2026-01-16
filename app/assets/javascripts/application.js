// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require link_to_add_fields
//= require twitter/bootstrap
//= require twitter/bootstrap/modal
//= require Chart.bundle
//= require chartkick
//= require turbolinks
//= require jquery.tokeninput
//= require_tree .

$(document).ajaxComplete(function(){
  $('#molecule-lookup-form').on('ajax:complete', function(event, data, status){
    $('#results').html(data.responseText)
  })
})

$(document).ajaxComplete(function(){
  $('#cidmolecule-lookup-form').on('ajax:complete', function(event, data, status){
    $('#cidresults').html(data.responseText)
  })
})

$(document).ajaxComplete(function(){
  $('#interaction-lookup-form').on('ajax:complete', function(event, data, status){
    $('#results').html(data.responseText)
  })
})



$(document).ajaxComplete(function(){
  $('#solvent-lookup-form').on('ajax:complete', function(event, data, status){
    $('#results').html(data.responseText)
  })
})

$(document).ajaxComplete(function(){
  $('#additive-lookup-form').on('ajax:complete', function(event, data, status){
    $('#results').html(data.responseText)
  })
})

$(document).ajaxComplete(function(){
  $('#cidadditive-lookup-form').on('ajax:complete', function(event, data, status){
    $('#cidresults').html(data.responseText)
  })
})

$(document).ajaxComplete(function(){
  $('#cidsolvent-lookup-form').on('ajax:complete', function(event, data, status){
    $('#cidresults').html(data.responseText)
  })
})

$(document).ready(function () {
    $("#sidenav").affix({
        offset: {
            bottom: 195
        }
    });
});

//
// $(document).on('ready turbolinks:load', function() {
//   $('.has-tooltip').tooltip();
//   $('.has-popover').popover();
// });

document.addEventListener("turbolinks:before-cache", function () {
    $('[data-toggle="tooltip"]').tooltip('hide');
});

document.addEventListener("turbolinks:before-cache", function () {
    $('[data-toggle="popover"]').popover('hide');
});

document.addEventListener("turbolinks:before-cache", function () {
    $('[data-toggle="ajax-tooltip"]').tooltip('hide');
});

document.addEventListener("turbolinks:before-cache", function () {
    $('[data-toggle="ajax-popover"]').popover('hide');
});


var searchButtons_clicked = 0;

var dataTable = null

document.addEventListener("turbolinks:before-cache", function () {
    if (dataTable !== null) {
     dataTable.destroy();
     dataTable = null;
   };
});

$(document).on('ready turbolinks:load',function(){

    $('[data-toggle="popover"]').popover({

        placement : 'right',

        trigger : 'click',

        html : true,
    });

});

//
// $(document).ajaxComplete(function() {
//   $('.has-ajax-tooltip').tooltip();
//   $('.has-ajax-popover').popover();
// });

$(document).ajaxComplete(function(){

    $('[data-toggle="ajax-popover"]').popover({

        placement : 'right',

        trigger : 'click',

        html : true,
    });

});


// $(document).ajaxComplete(function(){
//
//     $('[data-toggle="popover"]').popover({
//
//         placement : 'bottom',
//
//         trigger : 'click',
//
//         html : true,
//     });
//
// });

$(document).ajaxComplete(function(){

    $('[data-toggle="ajax-tooltip"]').tooltip({
       container: 'body',
        placement : 'right',
        trigger : 'hover',
        html : true,
    });

});

$(document).on('ready turbolinks:load',function(){

    $('[data-toggle="tooltip"]').tooltip({
        container: 'body',
        placement : 'right',
        trigger : 'hover',
        html : true,
    });

});

$(document).on('ready turbolinks:load',function(){
  $(".dataTables_filter label").addClass("bootstrap-label")
});

$(document).ajaxComplete(function(){
  $(".dataTables_filter label").addClass("bootstrap-label")
});


$(document).on('ready turbolinks:load',function(){
  $("a.bibtex-export").empty()
  $("a.bibtex-export").append("<span class=download-text> Bibtex</span>")
  $("a.ris-export").empty()
  $("a.ris-export").append("<span class=download-text> RIS</span>")
  $("a.endnote-export").empty()
  $("a.endnote-export").append("<span class=download-text> EndNote</span>")

});
