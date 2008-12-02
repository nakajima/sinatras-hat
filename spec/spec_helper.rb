$LOAD_PATH << File.join(File.dirname(__FILE__), 'fixtures')
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'spec'
require 'rr'
require 'json'
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

def stub_record
  @response = nil
  @record = Object.new
  stub(@record).id.returns(3)
  stub(@record).name.returns("Frank")
  stub(@record).to_json.returns(:a_result)
  stub(@record).to_xml.returns(:a_result)
  stub(Foo).first(:id => '3').returns(@record)
end

Spec::Runner.configure do |config|
  config.mock_with :rr
  config.before(:each) { stub_record }
end

def log(msg)
  puts "<pre>" + msg + "</pre>"
end