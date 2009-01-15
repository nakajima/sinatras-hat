require 'spec/spec_helper'

describe Sinatra::Hat::Router do
  describe "initialization" do
    it "takes an instance of Maker" do
      proc {
        maker = new_maker
        Sinatra::Hat::Router.new(maker)
      }.should_not raise_error
    end
  end
  
  describe "#generate" do
    attr_reader :app, :maker, :router
    
    before(:each) do
      @app = mock_app { set :views, fixture('views') }
      @maker = new_maker
      @router = Sinatra::Hat::Router.new(maker)
      stub.proxy(app).get(anything)
    end
    
    it "takes a Sinatra app" do
      router.generate(app)
    end

    describe "generating index route" do
      it "uses the maker's resource path" do
        mock.proxy(app).get('/articles')
        mock.proxy(app).get('/articles.:format')
        router.generate(app)
      end
      
      it "calls the block, passing the request" do
        router.generate(app)
        mock.proxy(maker).handle(:index, anything) { "" }
        get '/articles.yaml'
      end
    end
    
    describe "generating show route" do
      it "uses the maker's resource path" do
        mock.proxy(app).get('/articles/:id')
        mock.proxy(app).get('/articles/:id.:format')
        router.generate(app)
      end
      
      it "calls the block, passing the request" do
        router.generate(app)
        mock.proxy(maker).handle(:show, anything) { "" }
        get '/articles/1.yaml'
      end
    end
    
    describe "generating create route" do
      it "uses the maker's resource path" do
        mock.proxy(app).post('/articles')
        mock.proxy(app).post('/articles.:format')
        router.generate(app)
      end
      
      it "calls the block, passing the request" do
        router.generate(app)
        mock(maker).handle(:create, anything)
        post '/articles', "maker[name]" => "Pat"
      end
    end
    
    describe "generating new route" do
      it "uses the maker's resource path" do
        mock.proxy(app).get('/articles/new')
        mock.proxy(app).get('/articles/new.:format')
        router.generate(app)
      end
      
      it "calls the block, passing the request" do
        router.generate(app)
        mock.proxy(maker).handle(:new, anything) { "" }
        get '/articles/new'
      end
    end
    
    describe "generating destroy route" do
      it "uses the maker's resource path" do
        mock.proxy(app).delete('/articles/:id')
        mock.proxy(app).delete('/articles/:id.:format')
        router.generate(app)
      end
      
      it "calls the block, passing the request" do
        router.generate(app)
        mock.proxy(maker).handle(:destroy, anything) { "" }
        delete "/articles/#{@article.to_param}"
      end
    end
    
    describe "generating edit route" do
      it "uses the maker's resource path" do
        mock.proxy(app).get('/articles/:id/edit')
        mock.proxy(app).get('/articles/:id/edit.:format')
        router.generate(app)
      end
      
      it "calls the block, passing the request" do
        router.generate(app)
        mock.proxy(maker).handle(:edit, anything) { "" }
        get "/articles/#{@article.to_param}/edit"
      end
    end
    
    describe "generating update route" do
      it "uses the maker's resource path" do
        mock.proxy(app).put('/articles/:id')
        mock.proxy(app).put('/articles/:id.:format')
        router.generate(app)
      end
      
      it "calls the block, passing the request" do
        router.generate(app)
        mock.proxy(maker).handle(:update, anything) { "" }
        put "/articles/#{@article.to_param}"
      end
    end
  end
end
