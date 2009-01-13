require 'spec/spec_helper'

describe "handle index" do
  attr_reader :maker, :app, :request
  
  before(:each) do
    mock_app {  }
    @maker = new_maker(Article)
    @request = fake_request
  end
  
  def handle(*args)
    maker.handle(:index, *args)
  end
  
  it "takes a request" do
    maker.handle(:index, request)
  end
  
  it "loads all records" do
    mock.proxy(maker.model).all(anything) { [] }
    handle(request)
  end
  
  describe "rendering a response" do
    context "when there's a :format param" do
      before(:each) do
        @request = fake_request(:format => "yaml")
        stub(maker.model).all(anything).returns([:article])
      end
      
      it "serializes the data in the appropriate format" do
        mock.proxy(maker.responder).serialize(request, [:article])
        handle(request)
      end
    end
    
    context "when there's no :format param" do
      before(:each) do
        @request = fake_request
        stub(maker.model).all(anything).returns([:article])
      end
      
      it "renders the index template" do
        mock.proxy(maker.responder).success(:index, request, [:article])
        handle(request)
      end
    end
  end
end