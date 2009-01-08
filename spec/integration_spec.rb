require 'spec/spec_helper'

describe "integration level tests" do

  before(:each) do
    mock_app do
      set :views, fixture('views')
      
      mount(Article) do
        mount(Comment)
      end
      
      get "/" do
        "Hello!"
      end
    end
  end
  
  it "works like a normal Sinatra app" do
    get "/"
    body.should == "Hello!"
  end
  
  describe "index" do
    context "when serialized" do
      it "returns serialized index" do
        get "/articles.yaml"
        body.should == [:first_article, :second_article].to_yaml
      end
    end
    
    context "when template" do
      it "returns rendered template" do
        get "/articles"
        body.should == "HEY: [:first_article, :second_article]"
      end
    end
    
    context "when nested" do
      it "returns serialized index" do
        get '/articles/1/comments.yaml'
        body.should == [:first_comment, :second_comment].to_yaml        
      end
    end
  end
end
