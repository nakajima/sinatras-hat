ARGV.clear

$LOAD_PATH << File.join(File.dirname(__FILE__), '..')

require 'rubygems'
require 'spec'
require 'rr'
require 'sinatra/base'
require 'sinatra/test'
require 'sinatra/test/rspec'

# What we're testing:
require 'lib/sinatras-hat'

# Tired of stupid mocks
require 'acts_as_fu/base'

def fixture(path)
  File.join(File.dirname(__FILE__), 'fixtures', path)
end

Spec::Runner.configure do |config|
  config.mock_with :rr
  config.include Sinatra::Test
end

include ActsAsFu

build_model(:articles) do
  string :name
  string :description
  timestamps
  
  has_many :comments
  
  def self.all
    super(:order => 'created_at DESC')
  end
end

build_model(:comments) do
  string :name
  integer :article_id
  
  belongs_to :article
end

module Sinatra::Test
  # Sets up a Sinatra::Base subclass defined with the block
  # given. Used in setup or individual spec methods to establish
  # the application.
  def mock_app(base=Sinatra::Base, &block)
    @app = Sinatra.new(base, &block)
  end
end

def build_models!
  Article.delete_all
  Comment.delete_all
  @article = Article.create! :name => "An article"
  @non_child = @article.comments.create! :name => "Non child!"
  @comment = @article.comments.create! :name => "The child comment"
end

def new_maker(klass=Article, *args, &block)
  Sinatra::Hat::Maker.new(klass, *args, &block)
end

def fake_request(options={})
  app = Sinatra.new
  app.set :views, fixture("views")
  request = app.new
  stub(request).env.returns({ })
  stub(request).params.returns(options)
  stub(request).response.returns(Sinatra::Response.new)
  stub(request).last_modified(anything)
  stub(request).etag(anything)
  stub(request).not_found
  request
end

