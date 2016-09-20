module Turbolinks
  # Corrects the behavior of url_for (and link_to, which uses url_for) with the :back
  # option by using the X-XHR-Referer request header instead of the standard Referer
  # request header.
  module XHRUrlFor
    def url_for(options = {})
      options = (controller.request.headers["X-XHR-Referer"] || options) if options == :back
      super options
    end
  end
end
