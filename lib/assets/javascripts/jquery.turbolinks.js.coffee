callbacks = []

ready = ->
  callback jQuery for callback in callbacks

turbolinksReady = ->
  jQuery.isReady = true
  ready()

fetch = ->
  jQuery(document).off undefined, '**'
  jQuery.isReady = false

jQuery ready

jQuery.fn.ready = (callback) ->
  callbacks.push callback
  callback() if jQuery.isReady

jQuery.setReadyEvent = (event) ->
  jQuery(document)
    .off('.turbolinks-ready')
    .on(event + '.turbolinks-ready', turbolinksReady)

jQuery.setFetchEvent = (event) ->
  jQuery(document)
    .off('.turbolinks-fetch')
    .on(event + '.turbolinks-fetch', fetch)

jQuery.setReadyEvent 'page:load'
jQuery.setFetchEvent 'page:fetch'
