require 'rubygems'
require 'dm-core'
require 'dm-serializer'
require 'sinatra'

require File.join(File.dirname(__FILE__), '..', 'lib', 'sinatras-hat')

Rack::File::MIME_TYPES['atom'] = 'application/atom+xml'
Rack::File::MIME_TYPES['rss'] = 'application/rss+xml'

class Post
  include DataMapper::Resource
  include DataMapper::Serialize

  property :id, Serial, :key => true
  property :name, String
  property :body, Text
end

configure do
  DataMapper.setup(:default, 'sqlite3:db.sqlite3')
  Post.auto_migrate!
  Post.create :name => 'A test', :body => "Some sort of thing"
  Post.create :name => 'Another test', :body => "This is some other sort of thing"
end

get '/' do
  redirect '/posts'
end

mount(Post) do |klass, model|
  klass.protect = [:create]
  klass.accepts[:yaml] = proc { |content| YAML.load(content) }
  klass.formats[:ruby] = proc { |content| "<pre>#{content.inspect}</pre>" }
  klass.formats[:atom] = proc { |content| "<atom>\n  #{content.to_xml}\n</atom>" }
  klass.formats[:rss]  = proc { |content| "<rss>\n  #{content.to_xml}\n</rss>" }
end
