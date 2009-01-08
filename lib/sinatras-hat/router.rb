module Sinatra
  module Hat
    class Router
      delegate :resource_path, :to => :maker
      
      attr_reader :maker, :app
      
      def initialize(maker)
        @maker = maker
      end
      
      def generate(app)
        @app = app
        
        map resource_path('/:id') do |request|
          maker.handle_show(request)
        end

        map resource_path('/') do |request|
          maker.handle_index(request)
        end
      end
      
      private

      def map(path, &handler)
        get(path, handler)
        get("#{path}.:format", handler)
      end
      
      def get(path, block)
        app.get(path) { block.call(self) }
      end
    end
  end
end