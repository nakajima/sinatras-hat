module Sinatra
  module Hat
    # Tells Sinatra which routes to generate. The routes
    # created automatically when the actions are loaded.
    class Router
      delegate :resource_path, :logger, :to => :maker
      
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
        
        logger.info ">> route for #{maker.klass} #{action}:\t#{method.to_s.upcase}\t#{path}"
        
        app.send(method, path + "/?") { handler[self] }
        app.send(method, "#{path}.:format" + "/?") { handler[self] }        
      end
    end
  end
end