module Sinatra
  module Hat
    class Router
      delegate :resource_path, :to => :maker
      
      attr_reader :maker, :app
      
      def self.cache
        @cache ||= []
      end
      
      def initialize(maker)
        @maker = maker
      end
      
      def generate(app)
        @app = app
        
        Router.cache.each do |route|
          map(*route)
        end
      end
      
      private
      
      def map(method, action, path)
        path = resource_path(path)
        
        handler = lambda do |request|
          maker.handle(action, request)
        end
        
        app.send(method, path) { handler.call(self) }
        app.send(method, "#{path}.:format") { handler.call(self) }
      end
    end
  end
end