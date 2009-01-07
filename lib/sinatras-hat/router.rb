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
        get(maker.resource_path('/')) do |request|
          maker.handle_index(request)
        end
      end
      
      def get(path, &block)
        app.get(path) { block.call(self) }
      end
    end
  end
end