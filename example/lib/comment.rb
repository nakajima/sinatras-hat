require 'dm-core'
require 'dm-serializer'

class Comment
  include DataMapper::Resource
  include DataMapper::Serialize

  property :id, Serial, :key => true
  property :post_id, Integer
  property :body, Text
  
  belongs_to :post
end