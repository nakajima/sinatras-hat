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
    
    context "when the save is successful" do
      before(:each) do
        stub(Article).new(anything).returns(article)
        stub(article).save { true }
      end
      
      context "when there's no format" do
        it "redirects to that record's path" do
          mock(request).redirect("/articles/#{article.id}")
          mock.proxy(maker.responder).success(:create, request, article)
          handle(request)
        end
      end

      context "when there is a format" do
        it "serializes the record" do
          request_with_format = fake_request(:format => "yaml")
          mock.proxy(maker.responder).serialize("yaml", article)
          handle(request_with_format)
        end
      end
    end

    context "when the save is not successful" do
      before(:each) do
        stub(Article).new(anything).returns(article)
        stub(article).save { false }
      end
      
      context "when there's no format" do
        it "redirects to that record's path" do
          mock(request).erb(:new, :views_directory => fixture('views/articles'))
          mock.proxy(maker.responder).failure(:create, request, article)
          handle(request)
        end
      end

      # context "when there is a format" do
      #   it "serializes the record" do
      #     request_with_format = fake_request(:format => "yaml")
      #     mock.proxy(maker.responder).serialize("yaml", article)
      #     handle(request_with_format)
      #   end
      # end
    end
  end
end