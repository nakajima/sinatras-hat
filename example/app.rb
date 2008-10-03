require 'rubygems'
require 'dm-core'
require 'dm-serializer'
require 'sinatra'

require File.join(File.dirname(__FILE__), '..', 'lib', 'sinatra', 'hat')

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
end

mount(Post)
