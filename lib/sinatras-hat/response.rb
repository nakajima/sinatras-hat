module Sinatra
  module Hat
    # Tells Sinatra what to do next.
    class Response
      attr_reader :maker
      
      delegate :resource_path, :to => :maker
      
      def initialize(maker, request)
        @maker = maker
        @request = request
      end
      
      def render(action)
        @request.erb action.to_sym, :views_directory => views
      end
      
      def redirect(resource)
        @request.redirect url_for(resource)
      end
      
      private
      
      def views
        File.join(@request.options.views, maker.prefix)
      end
      
      def url_for(resource)
        case resource
        when String then resource
        else resource_path('/:id', resource)
        end
      end
    end
  end
end