require 'spec/spec_helper'

describe "handle create" do
  attr_reader :maker, :app, :request, :article
  
  before(:each) do
    build_models!
    mock_app {  }
    @maker = new_maker(Article)
    @request = fake_request("article[name]" => "Hooray!")
    stub(request).redirect(anything)
  end
  
  def handle(*args)
    maker.handle(:update, *args)
  end
  
  describe "when the record doesn't exist" do
    before(:each) do
      stub(maker.model).find(anything) { nil }
    end
    
    it "returns not_found" do
      mock.proxy(maker.responder).not_found(request)
      catch(:halt) { handle(request) }
    end
  end
  
  describe "attempting to update a record" do
    it "finds a record and updates its attributes" do
      mock.proxy(article).attributes = { "name" => "Hooray!" }
      mock.proxy(article).save
      mock.proxy(maker.model).find(anything) { article }
      handle(request)
    end
    
    context "when the save is successful" do
      before(:each) do
        stub(maker.model).find(anything).returns(article)
        stub(article).save { true }
      end
      
      context "when there's no format" do
        it "redirects to that record's path" do
          mock(request).redirect("/articles/#{article.id}")
          mock.proxy(maker.responder).success(:update, request, article)
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

    context "when the save is not successful" do
      before(:each) do
        stub(maker.model).find(anything).returns(article)
        stub(article).save { false }
      end
      
      context "when there's no format" do
        it "renders edit template" do
          mock(request).erb(:edit, :views_directory => fixture('views/articles'))
          mock.proxy(maker.responder).failure(:update, request, article)
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