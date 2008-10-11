# from http://www.gittr.com/index.php/archive/sinatra-basic-authentication-selectively-applied
module Sinatra
  module Authorization
    def auth
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
    end
 
    def unauthorized!(realm="myApp.com")
      header 'WWW-Authenticate' => %(Basic realm="#{realm}")
      throw :halt, [ 401, 'Authorization Required' ]
    end
 
    def bad_request!
      throw :halt, [ 400, 'Bad Request' ]
    end
 
    def authorized?
      request.env['REMOTE_USER']
    end
 
    def authorize(username, password)
      username == 'admin'
    end
 
    def protect!
      return if authorized?
      unauthorized! unless auth.provided?
      bad_request! unless auth.basic?
      unauthorized! unless authorize(*auth.credentials)
      request.env['REMOTE_USER'] = auth.username
    end
 
    def admin?
      authorized?
    end
  end
end

helpers do
  include Sinatra::Authorization
end