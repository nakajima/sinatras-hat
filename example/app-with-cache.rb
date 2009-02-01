require File.dirname(__FILE__) + '/lib/common.rb'
require 'rack/cache'

class MountedApp < Sinatra::Base
  set :app_file, __FILE__
  set :logging, true
  
  use Rack::Cache do
    set :verbose, true
    set :metastore,   'heap:/'
    set :entitystore, 'heap:/'
  end
  
  get '/' do
    redirect '/posts'
  end
  
  mount(Post) do
    finder { |model, params| model.all }
    record { |model, params| model.first(:id => params[:id]) }
    
    caches :show do
      set :etag, 
    end
    
    # Mount children as a nested resource
    mount(Comment) do
      finder { |model, params| model.all }
      record { |model, params| model.first(:id => params[:id]) }
    end
  end
end

MountedApp.run!