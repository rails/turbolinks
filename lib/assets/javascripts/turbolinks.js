(function() {
  var anchoredLink, browserSupportsPushState, createDocument, crossOriginLink, extractLink, fetchReplacement, fullReplacement, handleClick, ignoreClick, newTabClick, noTurbolink, nonHtmlLink, reflectNewUrl, rememberInitialPage, replaceHTML, triggerPageChange, visit;

  visit = function(url) {
    if (typeof browserSupportsPushState !== "undefined" && browserSupportsPushState !== null) {
      reflectNewUrl(url);
      return fetchReplacement(url);
    } else {
      return document.location.href = url;
    }
  };

  fetchReplacement = function(url) {
    var xhr;
    xhr = new XMLHttpRequest;
    xhr.open('GET', url, true);
    xhr.setRequestHeader('Accept', 'text/html, application/xhtml+xml, application/xml');
    xhr.onload = function() {
      return fullReplacement(xhr.responseText, url);
    };
    xhr.onabort = function() {
      return console.log("Aborted turbolink fetch!");
    };
    return xhr.send();
  };

  fullReplacement = function(html, url) {
    replaceHTML(html);
    return triggerPageChange();
  };

  reflectNewUrl = function(url) {
    return window.history.pushState({
      turbolinks: true
    }, "", url);
  };

  triggerPageChange = function() {
    var event;
    event = document.createEvent('Events');
    event.initEvent('page:change', true, true);
    return document.dispatchEvent(event);
  };

  createDocument = (function() {
    var createDocumentUsingParser, createDocumentUsingWrite, testDoc, _ref;
    createDocumentUsingParser = function(html) {
      return (new DOMParser).parseFromString(html, "text/html");
    };
    createDocumentUsingWrite = function(html) {
      var doc;
      doc = document.implementation.createHTMLDocument("");
      doc.open("replace");
      doc.write(html);
      doc.close;
      return doc;
    };
    if (window.DOMParser) {
      testDoc = createDocumentUsingParser("<html><body><p>test");
    }
    if ((testDoc != null ? (_ref = testDoc.body) != null ? _ref.childNodes.length : void 0 : void 0) === 1) {
      return createDocumentUsingParser;
    } else {
      return createDocumentUsingWrite;
    }
  })();

  replaceHTML = function(html) {
    var doc, originalBody, title;
    doc = createDocument(html);
    originalBody = document.body;
    document.documentElement.appendChild(doc.body, originalBody);
    document.documentElement.removeChild(originalBody);
    if (title = doc.querySelector("title")) {
      return document.title = title.textContent;
    }
  };

  extractLink = function(event) {
    var link;
    link = event.target;
    while (!(link === document || link.nodeName === 'A')) {
      link = link.parentNode;
    }
    return link;
  };

  crossOriginLink = function(link) {
    return location.protocol !== link.protocol || location.host !== link.host;
  };

  anchoredLink = function(link) {
    return ((link.hash && link.href.replace(link.hash, '')) === location.href.replace(location.hash, '')) || (link.href === location.href + '#');
  };

  nonHtmlLink = function(link) {
    return link.href.match(/\.[a-z]+$/g) && !link.href.match(/\.html?$/g);
  };

  noTurbolink = function(link) {
    return link.getAttribute('data-no-turbolink') != null;
  };

  newTabClick = function(event) {
    return event.which > 1 || event.metaKey || event.ctrlKey;
  };

  ignoreClick = function(event, link) {
    return crossOriginLink(link) || anchoredLink(link) || nonHtmlLink(link) || noTurbolink(link) || newTabClick(event);
  };

  handleClick = function(event) {
    var link;
    link = extractLink(event);
    if (link.nodeName === 'A' && !ignoreClick(event, link)) {
      visit(link.href);
      return event.preventDefault();
    }
  };

  browserSupportsPushState = window.history && window.history.pushState && window.history.replaceState;

  rememberInitialPage = function() {
    return window.history.replaceState({
      turbolinks: true
    }, "", document.location.href);
  };

  if (browserSupportsPushState) {
    rememberInitialPage();
    window.addEventListener('popstate', function(event) {
      var _ref;
      if ((_ref = event.state) != null ? _ref.turbolinks : void 0) {
        return fetchReplacement(document.location.href);
      }
    });
    document.addEventListener('click', function(event) {
      return handleClick(event);
    });
  }

  this.Turbolinks = {
    visit: visit
  };

}).call(this);
