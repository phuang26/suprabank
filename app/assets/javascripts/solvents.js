$(document).on('turbolinks:load',function(){
  $('#solvent-dblookup-form').on('ajax:complete', function(event, data, status){
    $('#dbresults').html(data.responseText)
  })
})

$(document).on('turbolinks:load',function(){
  $('#solvent-pglookup-form').on('ajax:complete', function(event, data, status){
    $('#pgresults').html(data.responseText)
  })
})

$(document).on('turbolinks:load',function(){
  $('#solvent-lookup-form').on('ajax:complete', function(event, data, status){
    $('#results').html(data.responseText)
  })
})


$(document).on('turbolinks:load',function(){
  $('#cidsolvent-lookup-form').on('ajax:complete', function(event, data, status){
    $('#results').html(data.responseText)
  })
})
