cacheSize      = 10
currentState   = null
referer        = null
loadedAssets   = null
pageCache      = {}
createDocument = null
requestMethod  = document.cookie.match(/request_method=(\w+)/)?[1].toUpperCase() or ''
xhr            = null
usePrefetch    = false
prefetchCache  = null
prefetchTimer  = null
#Benchmark Use Only
startTime      = null

createXhrRequest = (url, sourceUrl) ->
  # Remove hash from url to ensure IE 10 compatibility
  safeUrl = removeHash url

  newXhr = new XMLHttpRequest
  newXhr.open 'GET', safeUrl, true
  newXhr.setRequestHeader 'Accept', 'text/html, application/xhtml+xml, application/xml'
  newXhr.setRequestHeader 'X-XHR-Referer', sourceUrl
  newXhr

fetchReplacement = (url, prefetch) ->
  triggerEvent 'page:fetch'
  usePrefetch = url
  startTime = new Date().getTime()
  if prefetch
    console.log "Prefetching"
    usePrefetch = null
  else if prefetchTimer
      clearTimeout prefetchTimer
      prefetchTimer = null

  if url isnt prefetchCache?.url or (prefetch and prefetchCache.url isnt url)
    xhr?.abort()
    xhr = createXhrRequest url, referer
    prefetchCache = {url: url, doc: null}
    xhr.onload = ->
      if prefetch && usePrefetch isnt url
        if doc = processResponse()
          prefetchCache.doc = doc
          prefetchCache.xhr = xhr
        else
          prefetchCache = null
      else
        if doc = processResponse()
          usePrefetch = null
          applyXhrResponse(url, doc)
          prefetchCache = null
        else
          document.location.href = url

    xhr.onloadend = -> xhr = null
    xhr.onabort   = -> rememberCurrentUrl()
    xhr.onerror   = -> 
      document.location.href = url
      prefetchCache = null

    xhr.send()
  else if prefetchCache.doc
    console.log "Using Cache"
    applyXhrResponse(prefetchCache.url, prefetchCache.doc, prefetchCache.xhr)
    prefetchCache = null

applyXhrResponse = (url, doc, cachedXhr) ->
  triggerEvent 'page:receive'
  reflectNewUrl url
  changePage extractTitleAndBody(doc)...
  reflectRedirectedUrl(cachedXhr)
  if document.location.hash
    document.location.href = document.location.href
  else
    resetScrollPosition()
  timeDiff = new Date().getTime() - startTime
  console.log "Page loaded in #{timeDiff}ms from Click"
  triggerEvent 'page:load'
      
prefetch = (url) ->  
  referer = document.location.href
  fetchReplacement url, true
    
  
  

fetchHistory = (position) ->
  cacheCurrentPage()
  page = pageCache[position]
  xhr?.abort()
  changePage page.title, page.body
  recallScrollPosition page
  triggerEvent 'page:restore'


cacheCurrentPage = ->
  pageCache[currentState.position] =
    url:       document.location.href,
    body:      document.body,
    title:     document.title,
    positionY: window.pageYOffset,
    positionX: window.pageXOffset

  constrainPageCacheTo cacheSize

pagesCached = (size = cacheSize) ->
  cacheSize = parseInt(size) if /^[\d]+$/.test size

constrainPageCacheTo = (limit) ->
  for own key, value of pageCache
    pageCache[key] = null if key <= currentState.position - limit
  return

changePage = (title, body, csrfToken, runScripts) ->
  document.title = title
  document.documentElement.replaceChild body, document.body
  CSRFToken.update csrfToken if csrfToken?
  removeNoscriptTags()
  executeScriptTags() if runScripts
  currentState = window.history.state
  triggerEvent 'page:change'

executeScriptTags = ->
  scripts = Array::slice.call document.body.querySelectorAll 'script:not([data-turbolinks-eval="false"])'
  for script in scripts when script.type in ['', 'text/javascript']
    copy = document.createElement 'script'
    copy.setAttribute attr.name, attr.value for attr in script.attributes
    copy.appendChild document.createTextNode script.innerHTML
    { parentNode, nextSibling } = script
    parentNode.removeChild script
    parentNode.insertBefore copy, nextSibling
  return

removeNoscriptTags = ->
  noscriptTags = Array::slice.call document.body.getElementsByTagName 'noscript'
  noscript.parentNode.removeChild noscript for noscript in noscriptTags
  return

reflectNewUrl = (url) ->
  if url isnt referer
    window.history.pushState { turbolinks: true, position: currentState.position + 1 }, '', url

reflectRedirectedUrl = (cachedXhr) ->
  cachedXhr = cachedXhr || xhr
  if location = cachedXhr.getResponseHeader 'X-XHR-Redirected-To'
    preservedHash = if removeHash(location) is location then document.location.hash else ''
    window.history.replaceState currentState, '', location + preservedHash

rememberCurrentUrl = ->
  window.history.replaceState { turbolinks: true, position: Date.now() }, '', document.location.href

rememberCurrentState = ->
  currentState = window.history.state

recallScrollPosition = (page) ->
  window.scrollTo page.positionX, page.positionY

resetScrollPosition = ->
  window.scrollTo 0, 0

removeHash = (url) ->
  link = url
  unless url.href?
    link = document.createElement 'A'
    link.href = url
  link.href.replace link.hash, ''

triggerEvent = (name) ->
  event = document.createEvent 'Events'
  event.initEvent name, true, true
  document.dispatchEvent event

pageChangePrevented = ->
  !triggerEvent 'page:before-change'

processResponse = ->
  clientOrServerError = ->
    400 <= xhr.status < 600

  validContent = ->
    xhr.getResponseHeader('Content-Type').match /^(?:text\/html|application\/xhtml\+xml|application\/xml)(?:;|$)/

  extractTrackAssets = (doc) ->
    (node.src || node.href) for node in doc.head.childNodes when node.getAttribute?('data-turbolinks-track')?

  assetsChanged = (doc) ->
    loadedAssets ||= extractTrackAssets document
    fetchedAssets  = extractTrackAssets doc
    fetchedAssets.length isnt loadedAssets.length or intersection(fetchedAssets, loadedAssets).length isnt loadedAssets.length

  intersection = (a, b) ->
    [a, b] = [b, a] if a.length > b.length
    value for value in a when value in b

  if not clientOrServerError() and validContent()
    doc = createDocument xhr.responseText
    if doc and !assetsChanged doc
      return doc

extractTitleAndBody = (doc) ->
  title = doc.querySelector 'title'
  [ title?.textContent, doc.body, CSRFToken.get(doc).token, 'runScripts' ]

CSRFToken =
  get: (doc = document) ->
    node:   tag = doc.querySelector 'meta[name="csrf-token"]'
    token:  tag?.getAttribute? 'content'

  update: (latest) ->
    current = @get()
    if current.token? and latest? and current.token isnt latest
      current.node.setAttribute 'content', latest

browserCompatibleDocumentParser = ->
  createDocumentUsingParser = (html) ->
    (new DOMParser).parseFromString html, 'text/html'

  createDocumentUsingDOM = (html) ->
    doc = document.implementation.createHTMLDocument ''
    doc.documentElement.innerHTML = html
    doc

  createDocumentUsingWrite = (html) ->
    doc = document.implementation.createHTMLDocument ''
    doc.open 'replace'
    doc.write html
    doc.close()
    doc

  # Use createDocumentUsingParser if DOMParser is defined and natively
  # supports 'text/html' parsing (Firefox 12+, IE 10)
  #
  # Use createDocumentUsingDOM if createDocumentUsingParser throws an exception
  # due to unsupported type 'text/html' (Firefox < 12, Opera)
  #
  # Use createDocumentUsingWrite if:
  #  - DOMParser isn't defined
  #  - createDocumentUsingParser returns null due to unsupported type 'text/html' (Chrome, Safari)
  #  - createDocumentUsingDOM doesn't create a valid HTML document (safeguarding against potential edge cases)
  try
    if window.DOMParser
      testDoc = createDocumentUsingParser '<html><body><p>test'
      createDocumentUsingParser
  catch e
    testDoc = createDocumentUsingDOM '<html><body><p>test'
    createDocumentUsingDOM
  finally
    unless testDoc?.body?.childNodes.length is 1
      return createDocumentUsingWrite


installPrefetchMonitor = ->
  document.addEventListener 'mouseover', handlePrefetchDelay, false
  document.addEventListener 'mousedown', handlePrefetch, false
  document.addEventListener 'touchstart', handlePrefetch, false

cancelPrefetch = ->
  if prefetchTimer
    clearTimeout prefetchTimer
    prefetchTimer = null

installClickHandlerLast = (event) ->
  unless event.defaultPrevented
    document.removeEventListener 'click', handleClick, false
    document.addEventListener 'click', handleClick, false

handlePrefetchDelay = (event) ->
  unless event.defaultPrevented
    link = extractLink event
    if link.nodeName is 'A' and !ignoreClick(event, link)
      link.addEventListener 'mouseout', cancelPrefetch, false
      if prefetchTimer
        clearTimeout prefetchTimer
        prefetchTimer = null

      prefetchTimer = setTimeout(->
        prefetch link.href
        prefetchTimer = null
      , 300)
      setTimeout(->
        link.removeEventListener 'mouseout', cancelPrefetch, false
      ,300)

handlePrefetch = (event) ->
  unless event.defaultPrevented
    link = extractLink event
    if link.nodeName is 'A' and !ignoreClick(event, link)
      if prefetchTimer
        clearTimeout prefetchTimer
        prefetchTimer = null

      prefetch link.href

handleClick = (event) ->
  unless event.defaultPrevented
    link = extractLink event
    if link.nodeName is 'A' and !ignoreClick(event, link)
      visit link.href unless pageChangePrevented()
      event.preventDefault()

extractLink = (event) ->
  link = event.target
  link = link.parentNode until !link.parentNode or link.nodeName is 'A'
  link

crossOriginLink = (link) ->
  location.protocol isnt link.protocol or location.host isnt link.host

anchoredLink = (link) ->
  ((link.hash and removeHash(link)) is removeHash(location)) or
    (link.href is location.href + '#')

nonHtmlLink = (link) ->
  url = removeHash link
  url.match(/\.[a-z]+(\?.*)?$/g) and not url.match(/\.html?(\?.*)?$/g)

noTurbolink = (link) ->
  until ignore or link is document
    ignore = link.getAttribute('data-no-turbolink')?
    link = link.parentNode
  ignore

targetLink = (link) ->
  link.target.length isnt 0

nonStandardClick = (event) ->
  event.which > 1 or event.metaKey or event.ctrlKey or event.shiftKey or event.altKey

ignoreClick = (event, link) ->
  crossOriginLink(link) or anchoredLink(link) or nonHtmlLink(link) or noTurbolink(link) or targetLink(link) or nonStandardClick(event)

initializeTurbolinks = ->
  rememberCurrentUrl()
  rememberCurrentState()
  createDocument = browserCompatibleDocumentParser()
  document.addEventListener 'click', installClickHandlerLast, true
  installPrefetchMonitor()
  window.addEventListener 'popstate', (event) ->
    state = event.state

    if state?.turbolinks
      if pageCache[state.position]
        fetchHistory state.position
      else
        visit event.target.location.href
  , false

browserSupportsPushState =
  window.history and window.history.pushState and window.history.replaceState and window.history.state != undefined

browserIsntBuggy =
  !navigator.userAgent.match /CriOS\//

requestMethodIsSafe =
  requestMethod in ['GET','']

if browserSupportsPushState and browserIsntBuggy and requestMethodIsSafe
  visit = (url) ->
    referer = document.location.href
    cacheCurrentPage()
    fetchReplacement url

  initializeTurbolinks()
else
  visit = (url) ->
    document.location.href = url

# Public API
#   Turbolinks.visit(url)
#   Turbolinks.pagesCached() 
#   Turbolinks.pagesCached(20)
@Turbolinks = { visit, pagesCached }
