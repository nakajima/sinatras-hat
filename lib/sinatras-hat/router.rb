module Sinatra
  module Hat
    class Router
      attr_reader :maker, :app
      
      def initialize(maker)
        @maker = maker
      end
      
      def generate(app)
        @app = app
        index!
      end
      
      private
      
      def index!
        path = maker.resource_path('/')
        handler = Proc.new { |request| maker.handle_index(request) }
        get(path, &handler)
        get("#{path}.:format", &handler)
      end
      
      def get(path, &block)
        app.get(path) { block.call(self) }
      end
    end
  end
end