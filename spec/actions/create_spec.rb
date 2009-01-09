require 'spec/spec_helper'

describe "handle create" do
  attr_reader :maker, :app, :request, :article
  
  before(:each) do
    mock_app {  }
    @maker = new_maker(Article)
    @request = fake_request("article[title]" => "The article")
    stub(request).redirect(anything)
  end
  
  def handle(*args)
    maker.handle(:create, *args)
  end
  
  it "instantiates a new record and saves it" do
    mock.proxy(article = Article.new).save
    mock.proxy(maker.model).new("article[title]" => "The article") { article }
    handle(request)
  end
  
  describe "responding" do
    before(:each) do
      @article = Article.new
    end
    
    context "when there's no format" do
      it "redirects to that record's path" do
        mock(Article).new(anything).returns(article)
        mock(request).redirect("/articles/#{article.id}")
        mock.proxy(maker.responder).handle(:create, request, article)
        handle(request)
      end
    end
    
    context "when there is a format" do
      before(:each) do
        stub(Article).new { article }
      end
      
      it "serializes the record" do
        request_with_format = fake_request(:format => "yaml")
        mock.proxy(maker.responder).serialize(request_with_format, article)
        handle(request_with_format)
      end
    end
  end
end