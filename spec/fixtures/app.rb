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
mount(Bar) do |klass|
  klass.finder = [:find, :all]
  klass.formats[:yaml] = proc { |string| YAML.load(string) }
end

mount(Fizz, :only => :index)
mount(Buzz, :only => [:index, :show])