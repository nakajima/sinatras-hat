require 'dm-core'
require 'dm-serializer'

class Post
  include DataMapper::Resource
  include DataMapper::Serialize

  property :id, Serial, :key => true
  property :name, String
  property :body, Text
  
  has n, :comments
end