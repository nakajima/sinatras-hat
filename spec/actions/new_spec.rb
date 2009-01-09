require 'spec/spec_helper'

describe "handle index" do
  attr_reader :maker, :app, :request
  
  before(:each) do
    mock_app {  }
    @maker = new_maker(Article)
    @request = fake_request
  end
  
  def handle(*args)
    maker.handle(:new, *args)
  end
  
  it "takes a request" do
    maker.handle(:new, request)
  end
  
  it "loads a new record" do
    mock.proxy(maker.model).new(anything) { :article }
    handle(request)
  end
  
  describe "rendering a response" do
    context "when there's no :format param" do
      before(:each) do
        @request = fake_request
        stub(maker.model).new(anything).returns(:article)
      end
      
      it "renders the index template" do
        mock.proxy(maker.responder).success(:new, request, :article)
        handle(request)
      end
    end
  end
end