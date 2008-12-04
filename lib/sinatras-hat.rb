$LOAD_PATH << File.join(File.dirname(__FILE__), 'core_ext')
$LOAD_PATH << File.join(File.dirname(__FILE__), 'sinatras-hat')

require 'erb'
require 'extlib'
require 'dm-core'
require 'dm-serializer'
require 'array'
require 'object'
require 'actions'
require 'child_actions'
require 'responses'
require 'helpers'
require 'maker'

load 'auth.rb'

Rack::File::MIME_TYPES['json'] = 'text/x-json'
Rack::File::MIME_TYPES['yaml'] = 'text/x-yaml'

def mount(model, opts={}, &block)
  Sinatra::Hat::Maker.new(model).define(self, opts, &block)
end