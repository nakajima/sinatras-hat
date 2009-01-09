require 'spec/spec_helper'

describe "handle show" do
  attr_reader :maker, :app, :request
  
  before(:each) do
    mock_app {  }
    @maker = new_maker(Article)
    @request = fake_request(:id => 2)
  end
  
  def handle(*args)
    maker.handle(:show, *args)
  end
  
  it "takes a request" do
    handle(request)
  end
  
  it "loads correct record" do
    mock.proxy(maker.model).find(:id => 2) { :article }
    handle(request)
  end
  
  describe "rendering a response" do
    context "when there's a :format param" do
      before(:each) do
        params = { :format => "yaml", :id => 2 }
        @request = fake_request(params)
        stub(maker.model).find(params).returns(:article)
      end
      
      it "serializes the data in the appropriate format" do
        mock.proxy(maker.responder).serialize(request, :article)
        handle(request)
      end
    end
    
    context "when there's no :format param" do
      before(:each) do
        params = { :id => 2 }
        @request = fake_request(params)
        stub(maker.model).find(params).returns(:article)
      end
      
      it "renders the index template" do
        mock.proxy(maker.responder).handle(:show, request, :article)
        handle(request)
      end
    end
  end
end
