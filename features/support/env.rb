require File.join(File.dirname(__FILE__), *%w[.. .. spec spec_helper])

Sinatra::Test.tap do |mod|
  mod.module_eval { remove_method(:should) }
  include mod
end

def mock_app(&block)
  @app = super
  @app.set :views, File.join(File.dirname(__FILE__), 'views')
  @app
end

require 'spec/expectations'
require 'acts_as_fu'

include ActsAsFu

build_model(:people) do
  string :name
end