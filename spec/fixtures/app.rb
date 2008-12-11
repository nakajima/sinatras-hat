require 'rubygems'
require 'sinatra'

set :app_file, __FILE__
set :views, File.join(File.dirname(__FILE__), 'views')

require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'sinatras-hat')

class Foo; end
class Bar; end
class Post; end
class Fizz; end
class Buzz; end
class Sekret; end
class Comment; end
class TopSekret; end

get('/') { "home" }
get('/hello/:name') { "Hello #{params[:name]}!" }

mount(Foo)
mount(Bar) do
  finder { |params| find(:all) }
  record { |params| find(params[:id]) }
  accepts[:yaml] = proc { |string| YAML.load(string) }
  formats[:html] = proc { |record| %(<h1>#{record.name}</h1>) }
end

mount(Post) do
  mount(Comment)
end

mount(Fizz, :only => :index)
mount(Buzz) do
  only :index, :show
end
mount(Sekret) do
  protect :index, :username => 'spec', :password => 'helper'
  create do |model, params|
    model.sekret_create(params[:sekret])
  end
end

mount TopSekret, :protect => :all