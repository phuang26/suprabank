
$(document).on('ready turbolinks:load', function() {
  return $('#user_group_name').autocomplete({
    source: $('#user_group_name').data('autocomplete-source')
  });
});
