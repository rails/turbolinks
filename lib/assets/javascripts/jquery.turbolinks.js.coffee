callbacks = []

ready = ->
  callback(jQuery) for callback in callbacks

jQuery ready

jQuery.fn.ready = (callback) ->
  callbacks.push callback

jQuery.setReadyEvent = (event) ->
  jQuery(document)
    .off('.turbolinks')
    .on(event + '.turbolinks', ready)

jQuery.setReadyEvent 'page:load'
