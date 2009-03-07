require File.dirname(__FILE__) + '/lib/common.rb'

class MountedApp < Sinatra::Base
  set :app_file, __FILE__
  set :logging, true
  
  get '/' do
    "You created a post, and this is a custom response."
  end
  
  mount(Post) do
    finder { |model, params| model.all }
    record { |model, params| model.first(:id => params[:id]) }
    
    # Mount children as a nested resource
    mount(Comment) do
      finder { |model, params| model.all }
      record { |model, params| model.first(:id => params[:id]) }
    end
  end
end

MountedApp.run! if __FILE__ == $0