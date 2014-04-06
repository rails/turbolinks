module Turbolinks
  # Corrects the behavior of url_for (and link_to, which uses url_for) with the :back 
  # option by using the X-XHR-Referer request header instead of the standard Referer 
  # request header.
  module XHRUrlFor
    extend ActiveSupport::Concern

    included do
      alias_method_chain :url_for, :xhr_referer
    end

    def url_for_with_xhr_referer(options = {})
      options = (xhr_referer || options) if options == :back
      url_for_without_xhr_referer options
    end

    private
    def xhr_referer
      controller.request.headers["X-XHR-Referer"]
    end
  end
end
