require 'rubygems'
require 'sinatra'
require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'sinatra', 'hat')

class Foo; end
class Bar; end
class Fizz; end
class Buzz; end

get('/') { "home" }
get('/hello/:name') { "Hello #{params[:name]}!" }

mount(Foo)
mount(Bar) do |klass, model|
  klass.finder = proc { |params| model.find(:all) }
  klass.record = proc { |params| model.find(params[:id]) }
  klass.accepts[:yaml] = proc { |string| YAML.load(string) }
  klass.formats[:html] = proc { |record| %(<h1>#{record.name}</h1>) }
end

mount(Fizz, :only => :index)
mount(Buzz, :only => [:index, :show])