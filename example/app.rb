require 'rubygems'
require 'dm-core'
require 'dm-serializer'
require 'sinatra'

require File.join(File.dirname(__FILE__), '..', 'lib', 'sinatras-hat')

Rack::File::MIME_TYPES['ruby'] = 'text/x-ruby'

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
  # Protects the create and destroy actions using basic auth
  protect :create, :destroy, :username => 'bliggety', :password => 'blam'
  
  # Allows for params[:post] to just be a YAML string which will
  # get parsed into an attributes hash for updating a record
  accepts[:yaml] = proc { |content| YAML.load(content) }
  
  # Allows for a custom response format for when requests come in
  # as .ruby
  formats[:ruby] = proc { |content| content.inspect }
end
