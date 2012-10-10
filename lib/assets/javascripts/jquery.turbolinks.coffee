###
  jquery.turbolinks.js ~ v0.2.0 ~ https://github.com/kossnocorp/jquery.turbolinks

  jQuery plugin for drop-in fix binded events problem caused by Turbolinks

  The MIT License

  Copyright (c) 2012 Sasha Koss
###

$ = require?('jquery') || window.jQuery

# List for store callbacks passed to `$` or `$.ready`
callbacks = []

# Call each callback in list
ready = ->
  callback() for callback in callbacks

# Bind `ready` to DOM ready event
$(ready)

# Store callbacks in list on `$` and `$.ready`
$.fn.ready = (callback) ->
  callbacks.push(callback)

# Bind ready to passed event
$.setReadyEvent = (event) ->
  $(document)
    .off('.turbolinks')
    .on(event + '.turbolinks', ready)

# Bind `ready` to Tubolinks page load event
$.setReadyEvent('page:load')
