require 'spec/spec_helper'

describe "handle show" do
  attr_reader :maker, :app, :request
  
  before(:each) do
    build_models!
    mock_app {  }
    @maker = new_maker(Article)
    @request = fake_request(:id => @article.to_param)
  end
  
  def handle(*args)
    maker.handle(:show, *args)
  end
  
  it "takes a request" do
    handle(request)
  end
  
  it "loads correct record" do
    mock.proxy(maker.model).find(:id => @article.to_param) { :article }
    handle(request)
  end
  
  describe "rendering a successful response" do
    context "when there's a :format param" do
      before(:each) do
        params = { :format => "yaml", :id => @article.to_param }
        @request = fake_request(params)
        stub(maker.model).find(params).returns(@article)
      end
      
      it "serializes the data in the appropriate format" do
        mock.proxy(maker.responder).serialize(request, @article)
        handle(request)
      end
      
      it "sets last_modified header" do
        mock(request).last_modified(@article.updated_at)
        handle(request)
      end
      
      it "sets ETag header" do
        mock(request).etag(anything)
        handle(request)
      end
    end
    
    context "when there's no :format param" do
      before(:each) do
        params = { :id => @article.to_param }
        @request = fake_request(params)
        stub(maker.model).find(anything).returns(@article)
      end
      
      it "uses the success response" do
        mock.proxy(maker.responder).success(:show, request, @article)
        handle(request)
      end
      
      it "sets last_modified param" do
        mock(request).last_modified(@article.updated_at)
        handle(request)
      end
      
      it "sets ETag header" do
        mock(request).etag(anything)
        handle(request)
      end
    end
  end
  
  describe "rendering not_found" do
    before(:each) do
      stub(maker.model).find(request.params).returns(nil)
      stub(request).not_found # because it throws :halt otherwise
    end
    
    it "returns not_found" do
      mock(request).not_found
      handle(request)
    end
    
    it "does not set last_modified param" do
      mock(request).last_modified(@article.updated_at).never
      handle(request)
    end
  end
end
