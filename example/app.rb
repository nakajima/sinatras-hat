require 'rubygems'
require 'dm-core'
require 'dm-serializer'
require 'erector'
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
  Post.create :name => 'Another test', :body => "This is some other sort of thing"
end

mount(Post) do |klass, model|
  klass.accepts[:yaml] = proc { |string| YAML.load(string) }
  klass.formats[:html] = proc do |record|
    [record].flatten.map do |obj|
      buffer = ""
      buffer += "<h1>#{obj.name}</h1>"
      buffer += "\n"
      buffer += "<p>#{obj.body}</p>"
      buffer += "\n"
      buffer += "<br>"
      buffer
    end.join("\n\n")
  end
end
