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
        post :create, resource_path('/')
        
        # SHOW
        get :show, resource_path('/:id')

        # INDEX
        get :index, resource_path('/')
      end
      
      private
      
      def get(action, path)
        map :get, action, path
      end
      
      def post(action, path)
        map :post, action, path
      end

      def map(method, action, path)
        handler = lambda { |request| maker.handle(action, request) }
        app.send(method, path) { handler.call(self) }
        app.send(method, "#{path}.:format") { handler.call(self) }
      end
    end
  end
end