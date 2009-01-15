require 'spec/spec_helper'

describe "handle destroy" do
  attr_reader :maker, :app, :request, :article
  
  before(:each) do
    build_models!
    mock_app {  }
    @maker = new_maker(Article)
    @request = fake_request(:id => @article.to_param)
    stub(maker.model).find(:id => @article.to_param) { @article }
    stub(request).redirect(anything)
  end
  
  def handle(*args)
    maker.handle(:destroy, *args)
  end
  
  it "takes a request" do
    handle(request)
  end
  
  context "when the record exists" do
    it "loads correct record" do
      mock.proxy(maker.model).find(:id => @article.to_param) { article }
      handle(request)
    end

    it "destroys the record" do
      mock.proxy(article).destroy
      handle(request)
    end

    describe "rendering a response" do
      before(:each) do
        params = { :id => @article.to_param }
        @request = fake_request(params)
        stub(maker.model).find(params).returns(article)
      end

      it "redirects to the index" do
        mock(request).redirect('/articles')
        handle(request)
      end
    end
  end
  
  context "when the record does not exist" do
    before(:each) do
      stub(maker.model).find(:id => @article.to_param) { nil }
    end
    
    it "returns not_found" do
      mock.proxy(maker.responder).not_found(request)
      catch(:halt) { handle(request) }
    end
  end
end
