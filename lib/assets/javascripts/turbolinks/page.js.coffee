class @_Turbolinks.Page
  
  constructor: (page) ->
    @doc   = (new _Turbolinks.DocumentParser).create page
    @body  = @doc.body
    @title = @doc.querySelector('title')?.textContent
    
  assetsChanged: ->
    (@assets ?= new _Turbolinks.Assets).changed @doc

  change: ->
    document.title = @title
    document.documentElement.replaceChild @body, document.body
    
    @_executeScriptTags() unless @cache?
    @_setScrollPosition()
    
    _Turbolinks.State.save()
    
    new _Turbolinks.Event 'page:change'
  
  # Private
  
  _executeScriptTags: ->
    for script in document.body.getElementsByTagName 'script' when script.type in ['', 'text/javascript']
      copy = document.createElement 'script'
      copy.setAttribute attr.name, attr.value for attr in script.attributes
      copy.appendChild document.createTextNode script.innerHTML
      { parentNode, nextSibling } = script
      parentNode.removeChild script
      parentNode.insertBefore copy, nextSibling
      
  _setScrollPosition: ->
    window.scrollTo @positionX ? 0, @positionY ? 0