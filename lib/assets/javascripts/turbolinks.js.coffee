#= require turbolinks/turbolinks
#= require_directory ./turbolinks

browserSupportsPushState =
  window.history and window.history.pushState and window.history.replaceState and window.history.state != undefined

@Turbolinks = 
  if browserSupportsPushState 
    new _Turbolinks 
  else 
    { visit: (url) -> document.location.href = url }