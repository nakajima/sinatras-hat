require 'dm-core'
require 'dm-serializer'
require 'dm-timestamps'

class Post
  include DataMapper::Resource
  include DataMapper::Serialize

  property :id, Serial, :key => true
  property :name, String
  property :body, Text
  property :created_at, DateTime
  property :updated_at, DateTime
  
  has n, :comments
end