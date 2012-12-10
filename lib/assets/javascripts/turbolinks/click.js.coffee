class @_Turbolinks.Click
  
  @installHandlerLast: (event) =>
    unless event.defaultPrevented
      document.removeEventListener 'click', _Turbolinks.Click.handler
      document.addEventListener 'click', _Turbolinks.Click.handler

  @handler: (event) ->
    unless event.defaultPrevented
      (new _Turbolinks.Click event).go()
      
  constructor: (@event) ->
    @extractLink()
    
  extractLink: ->
    @link = @event.target
    @link = @link.parentNode until !@link.parentNode or @link.nodeName is 'A'
  
  go: ->
    if @link.nodeName is 'A' and !@_ignoreClick()
      Turbolinks.visit @link.href
      @event.preventDefault()
  
  # Private
  
  _ignoreClick: ->
    @_crossOriginLink() or @_anchoredLink() or @_nonHtmlLink() or @_noTurbolink() or @_targetLink() or @_nonStandardClick()
  
  _crossOriginLink: -> 
    location.protocol isnt @link.protocol or location.host isnt @link.host

  _anchoredLink: ->
    ((@link.hash and @link.href.replace(@link.hash, '')) is location.href.replace(location.hash, '')) or
      (@link.href is location.href + '#')

  _nonHtmlLink: ->
    @link.href.match(/\.[a-z]+(\?.*)?$/g) and not @link.href.match(/\.html?(\?.*)?$/g)

  _noTurbolink: ->
    link = @link
    until ignore or link is document
      ignore = link.getAttribute('data-no-turbolink')?
      link = link.parentNode
    ignore

  _targetLink: ->
    @link.target.length isnt 0

  _nonStandardClick: ->
    @event.which > 1 or @event.metaKey or @event.ctrlKey or @event.shiftKey or @event.altKey