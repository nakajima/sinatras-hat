# from http://www.gittr.com/index.php/archive/sinatra-basic-authentication-selectively-applied
# adapted by pat nakajima for sinatra's hat
module Sinatra
  module Hat
    module Authorization
      class ProtectedAction
        attr_reader :klass, :context
      
        def initialize(klass, context)
          @klass, @context = klass, context
        end
      
        def check!
          unauthorized! unless auth.provided?
          bad_request! unless auth.basic?
          unauthorized! unless authorize(*auth.credentials)
        end
      
        def username
          auth.username
        end
      
        private
      
        def authorize(username, password)
          klass.credentials[:username] == username and klass.credentials[:password] == password
        end
      
        def unauthorized!(realm="myApp.com")
          context.header 'WWW-Authenticate' => %(Basic realm="#{klass.realm}")
          throw :halt, [ 401, 'Authorization Required' ]
        end

        def bad_request!
          throw :halt, [ 400, 'Bad Request' ]
        end
      
        def auth
          @auth ||= Rack::Auth::Basic::Request.new(context.request.env)
        end
      end
    
      module Helpers
        def protect!(klass)
          return if authorized?
          guard = ProtectedAction.new(klass, self)
          guard.check!
          request.env['REMOTE_USER'] = guard.username
        end

        def authorized?
          request.env['REMOTE_USER']
        end
      end
    end
  end
end

helpers do
  include Sinatra::Hat::Authorization::Helpers
end