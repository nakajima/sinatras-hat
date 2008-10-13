# from http://www.gittr.com/index.php/archive/sinatra-basic-authentication-selectively-applied
# adapted by pat nakajima for sinatra's hat
module Sinatra
  module Hat
    module Authorization
      class ProtectedAction
        attr_reader :credentials, :context
      
        def initialize(context, credentials={})
          @credentials, @context = credentials, context
        end
      
        def check!
          unauthorized! unless auth.provided?
          bad_request! unless auth.basic?
          unauthorized! unless authorize(*auth.credentials)
        end

        def remote_user
          auth.username
        end

        private
      
        def authorize(username, password)
          credentials[:username] == username and credentials[:password] == password
        end
      
        def unauthorized!(realm="myApp.com")
          context.header 'WWW-Authenticate' => %(Basic realm="#{credentials[:realm]}")
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
        def protect!(credentials={})
          return if authorized?
          guard = ProtectedAction.new(self, credentials)
          guard.check!
          request.env['REMOTE_USER'] = guard.remote_user
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