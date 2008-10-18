$LOAD_PATH << File.join(File.dirname(__FILE__), 'fixtures')
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'rr'
require 'json'
require 'spec'
require 'sinatra'
require 'sinatra/test/rspec'
require 'app'

unless defined?(FOO_XML)
  FOO_XML = <<-XML
  <?xml version="1.0" encoding="UTF-8"?>
  <hash>
    <name>Frank</name>
  </hash>
  XML
  
  COMMENT_XML = <<-XML
  <?xml version="1.0" encoding="UTF-8"?>
  <hash>
    <name>Frank</name>
    <post_id>3</post_id>
  </hash>
  XML
end

Spec::Runner.configure do |config|
  config.mock_with :rr
end

def log(msg)
  puts "<pre>" + msg + "</pre>"
end