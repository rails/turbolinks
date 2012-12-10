class @_Turbolinks.State
  
  constructor: ->
    
  @current: null
  
  @save: (state = window.history.state) ->
    @current = state
  
  @setInitial: ->
    unless @current?
      @replace document.location.href, { turbolinks: true, position: Date.now() }
      @save()
    
  @push: (position, url) ->
    window.history.pushState { turbolinks: true, position: position + 1 }, '', url
    
  @replace: (url, state = @current) ->
    window.history.replaceState state, '', url