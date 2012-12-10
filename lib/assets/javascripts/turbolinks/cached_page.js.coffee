#= require turbolinks/page
class @_Turbolinks.Page.Cached extends @_Turbolinks.Page
  
  constructor: (page) ->
    @cache = true
    { @body, @title, @positionX, @positionY } = page