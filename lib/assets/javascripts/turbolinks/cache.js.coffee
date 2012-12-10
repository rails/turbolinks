class @_Turbolinks.Cache
  _cache = {}
  
  constructor: ->
    @state = _Turbolinks.State
      
  find: (position) -> 
    _cache[position]
  
  restore: (position, fallback) ->
    if page = @find position
      (new _Turbolinks.Page.Cached page).change()
      new _Turbolinks.Event 'page:restore'
    else
      fallback.call() 
    
  saveCurrentPage: ->
    @state.setInitial()
    @_save @state.current.position
    @_limit 10
    @
    
  reflectNewUrl: (url, updateReferer) ->
    if url isnt document.location.href
      updateReferer.call()
      @state.push @state.current.position + 1, url 

  reflectRedirectedUrl: (xhr) ->
    unless (location = xhr.getResponseHeader 'X-XHR-Current-Location') is document.location.pathname + document.location.search
      @state.replace location + document.location.hash
  
  # Private
  
  _save: (position) ->
    _cache[position] =
      url:       document.location.href,
      body:      document.body,
      title:     document.title,
      positionY: window.pageYOffset,
      positionX: window.pageXOffset
      
  _limit: (limit) ->
    for own key, value of _cache
      _cache[key] = null if key <= @state.current.position - limit