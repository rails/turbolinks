module Turbolinks
  # Provides a means of using Turbolinks to perform renders and redirects.
  # The server will respond with a JavaScript call to Turbolinks.visit/replace().
  module Redirection

    def redirect_to(url = {}, response_status = {})
      turbolinks, options = _extract_turbolinks_options!(response_status)

      value = super(url, response_status)

      if turbolinks || (turbolinks != false && request.xhr? && (options.size > 0 || !request.get?))
        _perform_turbolinks_response "Turbolinks.visit('#{location}'#{_turbolinks_js_options(options)});"
      end

      value
    end

    def render(*args, &block)
      render_options = args.extract_options!
      turbolinks, options = _extract_turbolinks_options!(render_options)

      super(*args, render_options, &block)

      if turbolinks || (turbolinks != false && request.xhr? && options.size > 0)
        _perform_turbolinks_response "Turbolinks.replace('#{view_context.j(response.body)}'#{_turbolinks_js_options(options)});"
      end

      self.response_body
    end

    def redirect_via_turbolinks_to(url = {}, response_status = {})
      ActiveSupport::Deprecation.warn("`redirect_via_turbolinks_to` is deprecated and will be removed in Turbolinks 3.1. Use redirect_to(url, turbolinks: true) instead.")
      redirect_to(url, response_status.merge!(turbolinks: true))
    end

    private
      def _extract_turbolinks_options!(options)
        turbolinks = options.delete(:turbolinks)
        extracted_options = options.extract!(:keep, :change, :flush).delete_if { |_, value| value.nil? }
        raise ArgumentError, "cannot combine :keep, :change and :flush options" if extracted_options.size > 1
        extracted_options.merge!(options.extract!(:scroll).delete_if { |_, value| value.nil? })
        [turbolinks, extracted_options]
      end

      def _perform_turbolinks_response(body)
        self.status           = 200
        self.response_body    = body
        response.content_type = Mime::JS
      end

      def _turbolinks_js_options(options)
        if options.length > 0
          js_options = ", {"
          if options[:change]
            js_options.concat("change: ['#{Array(options[:change]).join("', '")}']")
          elsif options[:keep]
            js_options.concat("keep: ['#{Array(options[:keep]).join("', '")}']")
          elsif options[:flush]
            js_options.concat("flush: true")
          end
          if options[:scroll].present?
            js_options.concat(", scroll: #{options[:scroll]}")
          end
          js_options += "}"
        end
      end
  end
end
