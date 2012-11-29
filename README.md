Turbolinks-js
=============

Same as Turbolinks but without the CoffeeScript requirement.
Check [Turbolinks](https://github.com/rails/turbolinks) for
more information.

Compatibility
-------------

Turbolinks is designed to work with any browser that fully supports pushState and all the related APIs. This includes Safari 6.0+ (but not Safari 5.1.x!), IE10, and latest Chromes and Firefoxes.

Do note that existing JavaScript libraries may not all be compatible with Turbolinks out of the box due to the change in instantiation cycle. You might very well have to modify them to work with Turbolinks' new set of events.


Installation
------------

1. Add `gem 'turbolinks-js'` to your Gemfile.
2. Run `bundle install`.
3. Add `//= require turbolinks` to your Javascript manifest file (usually found at `app/assets/javascripts/application.js`).
4. Restart your server and you're now using turbolinks!
