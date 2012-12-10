class @_Turbolinks

  constructor: ->
    @cache = new _Turbolinks.Cache
    @referer = document.location.href
    @_bindEventHandlers()
    
    { visit: @visit }

  visit: (url) =>
    @cache.saveCurrentPage().reflectNewUrl url, =>
      @referer = document.location.href
    @fetchReplacement url
  
  fetchReplacement: (url) ->
    new _Turbolinks.Event 'page:fetch'

    xhr = new XMLHttpRequest
    xhr.open 'GET', url, true
    xhr.setRequestHeader 'Accept', 'text/html, application/xhtml+xml, application/xml'
    xhr.setRequestHeader 'X-XHR-Referer', @referer

    xhr.onload = =>
      page = new _Turbolinks.Page xhr.responseText

      if page.assetsChanged()
        document.location.reload()
      else
        page.change()
        @cache.reflectRedirectedUrl xhr
        new _Turbolinks.Event 'page:load'

    xhr.onabort = -> console.log 'Aborted turbolink fetch!'

    xhr.send()

  fetchHistory: (state) ->
    @cache.saveCurrentPage().restore state.position, =>
      @fetchReplacement document.location.href
  
  # Private
      
  _bindEventHandlers: ->
    document.addEventListener 'click', _Turbolinks.Click.installHandlerLast, true
    window.addEventListener 'popstate', (event) =>
      @fetchHistory event.state if event.state?.turbolinks
    