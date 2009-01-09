$LOAD_PATH << File.join(File.dirname(__FILE__), '..', '..')
$LOAD_PATH << File.join(File.dirname(__FILE__))

require 'rubygems'
require 'sinatra'
require 'lib/sinatras-hat'

# Models
require 'post'
require 'comment'

configure do
  DataMapper.setup(:default, 'sqlite3:db.sqlite3')
  Post.auto_migrate!
  Comment.auto_migrate!
  Post.create :name => 'A test', :body => "Some sort of thing"
  new_post = Post.create :name => 'Another test', :body => "This is some other sort of thing"
  new_post.comments.create :body => "A comment"
end