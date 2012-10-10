callbacks = []

ready = ->
  callback() for callback in callbacks

$ ready

$.fn.ready = (callback) ->
  callbacks.push callback

$.setReadyEvent = (event) ->
  $(document)
    .off('.turbolinks')
    .on(event + '.turbolinks', ready)

$.setReadyEvent 'page:load'
