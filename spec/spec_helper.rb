$LOAD_PATH << File.join(File.dirname(__FILE__), 'fixtures')
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib', 'sinatra')

require 'rubygems'
require 'rr'
require 'json'
require 'spec'
require 'sinatra'
require 'sinatra/test/rspec'
require 'hat'
require 'app'

Spec::Runner.configure do |config|
  config.mock_with :rr
end