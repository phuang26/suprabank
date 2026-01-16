
$(document).on('ready turbolinks:load', function() {
  return $('#first_additive_name').autocomplete({
    source: $('#first_additive_name').data('autocomplete-source')
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
  return $('#first_solvent_name').autocomplete({
    source: $('#first_solvent_name').data('autocomplete-source')
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

$(document).on('turbolinks:load',function(){
  $('#buffer-dblookup-form').on('ajax:complete', function(event, data, status){
    $('#dbresults').html(data.responseText)
  })
})

//vol%
