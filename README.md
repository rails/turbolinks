Turbolinks
===========

Turbolinks makes following links in your web application faster. Instead of letting the browser recompile the JavaScript and CSS between each page change, and potentially spend extra HTTP requests checking if the assets are up-to-date, we keep the current instance alive and replace only the body and the title in the head. Think CGI vs persistent process.

This is similar to pjax, but instead of worrying about what element on the page to replace, and tailoring the server-side response to fit, we replace the entire body. This means that you get the bulk of the speed benefits from pjax (no recompiling of the JavaScript or CSS) without having to tailor the server-side response. It just works.

By default, all internal links will be funneled through Turbolinks, but you can opt out by marking links with data-no-turbolink. Additionally, links with data-remote will also be skipped as this will cause the request to be made with an unexpected Accept header (HTML instead of JS).


No jQuery or any other framework
--------------------------------

Turbolinks is designed to be as light-weight as possible (so you won't think twice about using it even for mobile stuff). It does not require jQuery or any other framework to work. But it works great _with_ jQuery or Prototype or whatever else have you.


The `page:change` event
---------------------

Since pages will change without a full reload with Turbolinks, you can't by default rely on `dom:loaded` to trigger your JavaScript code. Instead, Turbolinks uses the `page:change` event.

Installation
------------

1. Add `gem turbolinks` to your Gemfile.
1. Run `bundle install`.
1. Add `//= require turbolinks` to your Javascript manifest file (usually found at `app/assets/javascripts/application.js`).
1. Restart your server and you're now using turbolinks!

Triggering a Turbolinks visit manually
---------------------------------------

You can use `Turbolinks.visit(path)` to go to a URL through Turbolinks.


Available only for pushState browsers
-------------------------------------

Like pjax, this naturally only works with browsers capable of pushState. But of course we fall back gracefully to full page reloads for browsers that do not support it.


Work left to do
---------------

* CSS/JS asset change detection and reload
* Add a DOM cache for faster back button
* Remember scroll position when using back button 