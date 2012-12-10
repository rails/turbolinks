class @_Turbolinks.Event
  
  constructor: (@name) ->
    @trigger()

  trigger: ->
    event = document.createEvent 'Events'
    event.initEvent @name, true, true
    document.dispatchEvent event