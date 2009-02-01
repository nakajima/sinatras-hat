require 'spec/spec_helper'

class Article; end

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
        mock.proxy(request).erb :"articles/index"
        new_response.render(:index)
      end
      
      it "renders the show template" do
        mock.proxy(request).erb :"articles/show"
        new_response.render(:show)
      end
    end
    
    context "when there are options passed" do
      it "sends the options to the request" do
        mock(request).last_modified :yesterday
        new_response.render(:show, :last_modified => :yesterday)
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
    context "when passed a path" do
      it "redirects to the given path" do
        mock(request).redirect("/articles")
        new_response.redirect("/articles")
      end
    end
    
    context "when passed some data" do
      before(:each) do
        stub(@article = Article.new).id { 2 }
      end
      
      it "redirects to the resource path for that data" do
        mock(request).redirect("/articles/2")
        new_response.redirect(@article)
      end
    end
    
    context "when passed a symbol" do
      before(:each) do
        stub(@article = Article.new).id { 2 }
      end
      
      it "can redirect to the :index path" do
        mock(request).redirect("/articles")
        new_response.redirect(:index)
      end
      
      it "can redirect to the :show path" do
        mock(request).redirect("/articles/2")
        new_response.redirect(:show, @article)
      end
      
      it "can redirect to the :new path" do
        mock(request).redirect("/articles/new")
        new_response.redirect(:new)
      end
      
      it "can redirect to the :edit path" do
        mock(request).redirect("/articles/2/edit")
        new_response.redirect(:edit, @article)
      end
    end
  end
end
