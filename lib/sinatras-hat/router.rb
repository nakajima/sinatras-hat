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
        
        # CREATE
        map :post, resource_path('/') do |request|
          maker.handle_create(request)
        end
        
        # SHOW
        map :get, resource_path('/:id') do |request|
          maker.handle_show(request)
        end

        # INDEX
        map :get, resource_path('/') do |request|
          maker.handle_index(request)
        end
      end
      
      private

      def map(method, path, &handler)
        send(method, path, handler)
        send(method, "#{path}.:format", handler)
      end
      
      def get(path, block)
        app.get(path) { block.call(self) }
      end
      
      def post(path, block)
        app.post(path) { block.call(self) }
      end
    end
  end
end