module Turbolinks
  module XHRHeaders
    extend ActiveSupport::Concern

    included do
      alias_method_chain :_compute_redirect_to_location, :xhr_referer
    end

    private
      def _compute_redirect_to_location_with_xhr_referer(options)
        if options == :back && request.headers["X-XHR-Referer"]
          _compute_redirect_to_location_without_xhr_referer(request.headers["X-XHR-Referer"])
        else
          _compute_redirect_to_location_without_xhr_referer(options)
        end
      end

      def set_xhr_current_location
        response.headers['X-XHR-Current-Location'] = request.fullpath
      end
  end

  module AssetTracker
    private
      def check_assets
        cookies.delete :asset_digest
        yield
        if response.content_type.include? 'text/html'
          if request.headers['X-XHR-Asset-Digest']
            unless asset_digest == request.headers['X-XHR-Asset-Digest']
              response.headers['X-XHR-Assets-Changed'] = 'true'
              response.body = '' 
            end
          else
            cookies[:asset_digest] = asset_digest
          end
        end
      end
      
      def asset_digest
        @asset_digest ||= begin
          assets = []
          response.body.split('</head>').first.scan /\<(script|link)[\S\s]+?(src|href)="(\S+)"[\S\s]+?\>/ do |type, attr, asset| 
            assets << asset
          end
          Digest::MD5.hexdigest(assets.sort.join)
        end
      end
  end
  
  class Engine < ::Rails::Engine
    initializer :turbolinks_xhr_headers do |config|
      ActionController::Base.class_eval do
        include XHRHeaders, AssetTracker
        before_filter :set_xhr_current_location
        around_filter :check_assets
      end
    end
  end
end
