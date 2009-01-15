require 'spec/spec_helper'

describe "handle show" do
  attr_reader :maker, :app, :request
  
  before(:each) do
    mock_app {  }
    @maker = new_maker(Article)
    @request = fake_request(:id => @article.to_param)
  end
  
  def handle(*args)
    maker.handle(:edit, *args)
  end
  
  it "takes a request" do
    handle(request)
  end
  
  describe "rendering not_found" do
    before(:each) do
      stub(maker.model).find(request.params).returns(nil)
      stub(request).not_found # because it throws :halt otherwise
    end
    
    it "returns not_found" do
      mock.proxy(maker.responder).not_found(request)
      handle(request)
    end
  end
  
  describe "rendering a successful response" do
    it "loads correct record" do
      mock.proxy(maker.model).find(:id => @article.to_param) { :article }
      handle(request)
    end
    
    context "when there's no :format param" do
      before(:each) do
        params = { :id => @article.to_param }
        @request = fake_request(params)
        stub(maker.model).find(params).returns(:article)
      end
      
      it "renders the show template" do
        mock.proxy(maker.responder).success(:edit, request, :article)
        handle(request)
      end
    end
  end
end
