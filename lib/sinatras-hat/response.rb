module Sinatra
  module Hat
    class Response
      attr_reader :maker
      
      def initialize(maker, request)
        @maker = maker
        @request = request
      end
      
      def render(action)
        @request.erb action.to_sym, :views_directory => File.join(@request.options.views, maker.prefix)
      end
      
      def redirect(path, record=nil)
        @request.redirect(maker.resource_path(path, record))
      end
    end
  end
end