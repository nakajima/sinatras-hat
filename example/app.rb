require File.dirname(__FILE__) + '/lib/common.rb'

class MountedApp < Sinatra::Base
  set :app_file, __FILE__
  
  get '/' do
    @env['sinatra.error']
  end
  
  mount(Post) do
    # Mount children as a nested resource
    mount(Comment)

    after :create do |on|
      on.success { |post| redirect("/posts/#{post.id}") }
    end
  end
end

MountedApp.run!