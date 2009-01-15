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
require 'acts_as_fu'

def fixture(path)
  File.join(File.dirname(__FILE__), 'fixtures', path)
end

Spec::Runner.configure do |config|
  config.mock_with :rr
  config.include Sinatra::Test
  config.include ActsAsFu
end

Spec::Runner.configuration.before(:each) do
  build_model(:articles) do
    string :name
    string :description
    
    has_many :comments
  end
  
  build_model(:comments) do
    string :name
    integer :article_id
    
    belongs_to :article
  end
  
  @article = Article.create! :name => "An article"
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
  request
end

