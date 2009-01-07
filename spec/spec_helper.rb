ARGV.clear

$LOAD_PATH << File.join(File.dirname(__FILE__), '..')

require 'rubygems'
require 'spec'
require 'rr'
require 'sinatra/base'
require 'sinatra/test'
require 'sinatra/test/rspec'

# What we're testing:
require 'lib/sinatras-hat'

# Fixture models/views:
require 'spec/fixtures/lib/abstract'
require 'spec/fixtures/lib/comment'
require 'spec/fixtures/lib/article'

Spec::Runner.configure do |config|
  config.mock_with :rr
  config.include Sinatra::Test
end

def new_maker(klass=Article, *args, &block)
  Sinatra::Hat::Maker.new(klass, *args, &block)
end
