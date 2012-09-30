pageCache    = []
currentState = null
initialized  = false

visit = (url) ->
  if browserSupportsPushState
    cacheCurrentPage()
    reflectNewUrl url
    currentState = incrementState()
    fetchReplacement url
  else
    document.location.href = url


fetchReplacement = (url) ->
  triggerEvent 'page:fetch'

  xhr = new XMLHttpRequest
  xhr.open 'GET', url, true
  xhr.setRequestHeader 'Accept', 'text/html, application/xhtml+xml, application/xml'
  xhr.onload  = ->
    changePage extractTitleAndBody(xhr.responseText)...
    triggerEvent 'page:load'
  xhr.onabort = -> console.log 'Aborted turbolink fetch!'
  xhr.send()

fetchHistory = (state) ->
  cacheCurrentPage()

  if page = pageCache[state.position]
    changePage page.title, page.body.cloneNode(true)
    currentState = stateFromEvent(state)
    recallScrollPosition page
    triggerEvent 'page:restore'
  else
    fetchReplacement document.location.href


cacheCurrentPage = ->
  rememberInitialPage() unless initialized

  pageCache[currentState.position] =
    url:       document.location.href,
    body:      document.body,
    title:     document.title,
    positionY: window.pageYOffset,
    positionX: window.pageXOffset

  constrainPageCacheTo(10)

constrainPageCacheTo = (limit) ->
  delete pageCache[currentState.position - limit] if currentState.position == window.history.length - 1

changePage = (title, body) ->
  document.title = title
  document.documentElement.replaceChild body, document.body
  triggerEvent 'page:change'


reflectNewUrl = (url) ->
  if url isnt document.location.href
    window.history.pushState { turbolinks: true, position: currentState.position + 1 }, '', url

stateFromEvent = (state) ->
    window.history.state or { turbolinks: true, position: state.position }

incrementState = ->
    window.history.state or { turbolinks: true, position: currentState.position + 1 }

rememberInitialPage = ->  
  rememberInitialUrl()
  rememberInitialState()
  initialized = true

rememberInitialUrl = ->
  window.history.replaceState { turbolinks: true, position: window.history.length - 1 }, '', document.location.href

rememberInitialState = ->
  currentState = window.history.state or { turbolinks: true, position: window.history.length - 1 }

recallScrollPosition = (page) ->
  window.scrollTo page.positionX, page.positionY


triggerEvent = (name) ->
  event = document.createEvent 'Events'
  event.initEvent name, true, true
  document.dispatchEvent event


extractTitleAndBody = (html) ->
  doc   = createDocument html
  title = doc.querySelector 'title'
  [ title?.textContent, doc.body ]

createDocument = do ->
  createDocumentUsingParser = (html) ->
    (new DOMParser).parseFromString html, 'text/html'

  createDocumentUsingWrite = (html) ->
    doc = document.implementation.createHTMLDocument ''
    doc.open 'replace'
    doc.write html
    doc.close
    doc

  if window.DOMParser
    testDoc = createDocumentUsingParser '<html><body><p>test'

  if testDoc?.body?.childNodes.length is 1
    createDocumentUsingParser
  else
    createDocumentUsingWrite


handleClick = (event) ->
  link = extractLink event

  if link.nodeName is 'A' and !ignoreClick(event, link)
    visit link.href
    event.preventDefault()

extractLink = (event) ->
  link = event.target
  link = link.parentNode until link is document or link.nodeName is 'A'
  link

samePageLink = (link) ->
  link.href is document.location.href

crossOriginLink = (link) ->
  location.protocol isnt link.protocol or location.host isnt link.host

anchoredLink = (link) ->
  ((link.hash and link.href.replace(link.hash, '')) is location.href.replace(location.hash, '')) or
    (link.href is location.href + '#')

nonHtmlLink = (link) ->
  link.href.match(/\.[a-z]+(\?.*)?$/g) and not link.href.match(/\.html?(\?.*)?$/g)

remoteLink = (link) ->
  link.getAttribute('data-remote')?

noTurbolink = (link) ->
  link.getAttribute('data-no-turbolink')?

newTabClick = (event) ->
  event.which > 1 or event.metaKey or event.ctrlKey

ignoreClick = (event, link) ->
  samePageLink(link) or crossOriginLink(link) or anchoredLink(link) or
  nonHtmlLink(link)  or remoteLink(link)      or noTurbolink(link)  or 
  newTabClick(event)


browserSupportsPushState =
  window.history and window.history.pushState and window.history.replaceState

if browserSupportsPushState
  window.addEventListener 'popstate', (event) ->
    fetchHistory event.state if event.state?.turbolinks

  document.addEventListener 'click', (event) ->
    handleClick event

# Call Turbolinks.visit(url) from client code
@Turbolinks = {visit}
