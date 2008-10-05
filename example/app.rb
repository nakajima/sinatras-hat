require 'rubygems'
require 'dm-core'
require 'dm-serializer'
require 'erector'
require 'sinatra'

require File.join(File.dirname(__FILE__), '..', 'lib', 'sinatras_hat')

class Post
  include DataMapper::Resource
  include DataMapper::Serialize

  property :id, Serial, :key => true
  property :name, String
  property :body, Text
end

configure do
  DataMapper.setup(:default, 'sqlite3::memory:')
  Post.auto_migrate!
  Post.create :name => 'A test', :body => "Some sort of thing"
  Post.create :name => 'Another test', :body => "This is some other sort of thing"
end

mount(Post) do |klass, model|
  klass.accepts[:yaml] = proc { |string| YAML.load(string) }
  klass.formats[:ruby] = proc { |record| [record].flatten.map(&:inspect) }
end
