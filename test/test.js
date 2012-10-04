document.addEventListener("page:change", function() {
  console.log("page changed");
});

// Async Test
function loadEmptyJS() {
  if (document.location.href.match(/async.html/)) {
    var script = document.createElement('script');
    script.type = "text/javascript";
    script.src = 'empty.js';
    document.head.appendChild(script);
    document.removeEventListener("page:change", loadEmptyJS);
  } else {
    document.addEventListener("page:change", loadEmptyJS);
  }
}
Turbolinks.rememberInitialPage();
loadEmptyJS();
