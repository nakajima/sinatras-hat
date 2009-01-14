require 'spec/spec_helper'

describe Sinatra::Hat::Response do
  attr_reader :maker, :response, :request
  
  def new_response
    Sinatra::Hat::Response.new(maker, request)
  end
  
  before(:each) do
    @maker = new_maker
    @request = fake_request
    stub(request.options).views { fixture('views') }
  end

  describe "render()" do
    describe "rendering templates" do
      it "renders the index template" do
        mock.proxy(request).erb(:index, :views_directory => fixture('views/articles'))
        new_response.render(:index)
      end
      
      it "renders the show template" do
        mock.proxy(request).erb(:show, :views_directory => fixture('views/articles'))
        new_response.render(:show)
      end
    end
    
    context "when there is no views dir" do
      before(:each) do
        stub(request.options).views { nil }
      end
      
      it "raises Sinatra::NoTemplateError" do
        proc {
          new_response.render(:show)
        }.should raise_error(Sinatra::NoTemplateError)
      end
    end
    
    context "when the view does not exist" do
      it "raises Sinatra::NoTemplateError" do
        proc {
          new_response.render(:nonsense)
        }.should raise_error(Sinatra::NoTemplateError)
      end
    end
  end
  
  describe "redirect()" do
    it "redirects to the given path" do
      mock(request).redirect("/articles")
      new_response.redirect("/articles")
    end
  end
end
