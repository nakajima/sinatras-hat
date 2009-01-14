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
  
  describe "show" do
    before(:each) do
      stub(Article).first { :article }
    end
    
    context "when serialized" do
      it "returns serialized index" do
        get "/articles/1.yaml"
        body.should == :article.to_yaml
      end
    end
    
    context "when template" do
      it "returns rendered template" do
        get "/articles/1"
        body.should == "SHOW: :article"
      end
    end
  end
  
  describe "create" do
    attr_reader :article
    
    before(:each) do
      @article = Article.new
      stub(Article).new { article }
    end
    
    it "creates a new article" do
      post "/articles", "article[name]" => "Hello!"
      status.should == 302
      response['Location'].should == "/articles/#{article.id}"
    end
    
    context "with custom redirect" do
      before(:each) do
        mock_app do
          mount(Article) do
            after :create do |on|
              on.success { |data| redirect("/custom/path/#{data.id}") }
            end
          end
        end
      end
      
      it "allows custom redirect" do
        post "/articles"
        status.should == 302
        response['Location'].should == "/custom/path/#{article.id}"
      end
    end
  end
  
  describe "new" do
    it "shows a new template" do
      get "/articles/new"
      status.should == 200
      body.should == "New Article!"
    end
  end
  
  describe "edit" do
    it "shows a edit template" do
      get "/articles/2/edit"
      status.should == 200
      body.should == "Edit Article!"
    end
  end
end
