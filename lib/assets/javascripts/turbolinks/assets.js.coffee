class @_Turbolinks.Assets
  
  constructor: ->
    @loaded = null
    @fetched = null

  changed: (doc) ->
    @loaded ||= @_extract document
    @fetched  = @_extract doc
    @fetched.length isnt @loaded.length or @_intersection().length isnt @loaded.length

  # Private
  
  _extract: (doc) ->
    (node.src || node.href) for node in doc.head.childNodes when node.getAttribute?('data-turbolinks-track')?
    
  _intersection: ->
    [a, b] = [@fetched, @loaded]
    [a, b] = [b, a] if a.length > b.length
    value for value in a when value in b