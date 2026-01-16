$(document).on('turbolinks:load',function(){
  $('#additive-dblookup-form').on('ajax:complete', function(event, data, status){
    $('#dbresults').html(data.responseText)
  })
})

$(document).on('turbolinks:load',function(){
  $('#additive-pglookup-form').on('ajax:complete', function(event, data, status){
    $('#pgresults').html(data.responseText)
  })
})

$(document).on('turbolinks:load',function(){
  $('#additive-lookup-form').on('ajax:complete', function(event, data, status){
    $('#results').html(data.responseText)
  })
})

$(document).on('turbolinks:load',function(){
  $('#cidadditive-lookup-form').on('ajax:complete', function(event, data, status){
    $('#results').html(data.responseText)
  })
})
