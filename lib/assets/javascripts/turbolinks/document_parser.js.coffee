class @_Turbolinks.DocumentParser
  parser = null
  
  constructor: ->
    @create = (parser ?= @_chooseParser())

  # Private
  
  _chooseParser: ->
    createDocumentUsingParser = (html) ->
      (new DOMParser).parseFromString html, 'text/html'

    createDocumentUsingWrite = (html) ->
      doc = document.implementation.createHTMLDocument ''
      doc.open 'replace'
      doc.write html
      doc.close()
      doc

    if window.DOMParser
      testDoc = createDocumentUsingParser '<html><body><p>test'

    if testDoc?.body?.childNodes.length is 1
      createDocumentUsingParser
    else
      createDocumentUsingWrite