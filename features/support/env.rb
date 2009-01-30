require File.join(File.dirname(__FILE__), *%w[.. .. lib sinatras-hat])

require 'sinatra/test'
require 'acts_as_fu'

Sinatra::Test.module_eval do
  def mock_app(base=Sinatra::Base, &block)
    @app = Sinatra.new(base, &block)
  end
end

World do
  extend ActsAsFu
  extend Sinatra::Test
end

require 'spec/expectations'