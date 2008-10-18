$LOAD_PATH << File.join(File.dirname(__FILE__), '..', '..', 'lib')
$LOAD_PATH << File.join(File.dirname(__FILE__))

require 'rubygems'
require 'sinatra'
require 'sinatras-hat'

# Models
require 'post'
require 'comment'

configure do
  DataMapper.setup(:default, 'sqlite3:db.sqlite3')
  Post.auto_migrate!
  Post.create :name => 'A test', :body => "Some sort of thing"
  Post.create :name => 'Another test', :body => "This is some other sort of thing"
end