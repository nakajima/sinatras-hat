require File.dirname(__FILE__) + '/lib/common.rb'

class MountedApp < Sinatra::Base
  set :app_file, __FILE__
  set :logging, true
  mount(Post) do
    protect :index,
      :username => 'bliggety',
      :password => 'blam',
      :realm => "Use Protection"
  end
  
  run!
end