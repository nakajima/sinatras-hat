require 'spec/spec_helper'

class Article; end
class Comment; end

describe Sinatra::Hat::Maker do
  attr_reader :model, :maker, :request

  describe "initializing" do
    it "takes a klass" do
      proc {
        new_maker(Article)
      }.should_not raise_error
    end
    
    it "takes options" do
      proc {
        new_maker(Article, :only => :index)
      }.should_not raise_error
    end
    
    it "merges options hash with defaults" do
      maker = new_maker(Article, :only => :index)
      maker.options[:only].should == :index
    end
  end
  
  describe "setup" do
    before(:each) do
      stub.instance_of(Sinatra::Hat::Router).generate(:app)
    end
    
    it "stores reference to app" do
      maker = new_maker
      maker.setup(:app)
      maker.app.should == :app
    end
  end
  
  it "has a klass" do
    new_maker(Article).klass.should == Article
  end
  
  describe "protect" do
    before(:each) do
      @maker = new_maker
    end
    
    it "sets the protected actions" do
      maker.protect :index, :show
      maker.protect.should == [:index, :show]
    end
    
    it "can set the protected actions to :all" do
      maker.protect :all
      maker.protect.should == maker.only
    end
    
    it "can set the credentials" do
      maker.protect :username => "admin", :password => "awesome", :realm => "awesome app"
      maker.credentials.should == { :username => "admin", :password => "awesome", :realm => "awesome app" }
    end
  end
  
  describe "handling actions" do
    before(:each) do
      @request = fake_request
      @maker = new_maker
      stub(Sinatra::Hat::Maker.actions[:index])[:fn].returns proc { |passed_request| [self, passed_request] }
    end
    
    it "takes an action and instance_exec's its event handler" do
      mock(Sinatra::Hat::Maker.actions[:index])[:fn].returns proc { |passed_request| [self, passed_request] }
      maker.handle(:index, request).should == [maker, request]
    end
    
    context "when the action is protected" do
      before(:each) do
        maker.protect :index
      end
      
      context "when the user is not authenticated" do
        it "protects the action" do
          proc {
            maker.handle(:index, request)
          }.should throw_symbol(:halt)
        end
      end
      
      context "when the user is authenticated" do
        before(:each) do
          request.env['REMOTE_USER'] = 'hello'
        end
        
        it "allows the request" do
          proc {
            maker.handle(:index, request)
          }.should_not throw_symbol(:halt)
        end
      end
    end
    
    context "when the action is not part of the :only list" do
      before(:each) do
        maker.only :show
      end
      
      it "returns 404" do
        mock.proxy(request).error(404)
        catch(:halt) { maker.handle(:index, request) }
      end
    end

  end
  
  describe "default options" do
    before(:each) do
      @maker = new_maker(Article)
    end
    
    it "has a default options hash" do
      maker.options.should_not be_nil
    end
    
    describe ":only" do
      it "returns all actions" do
        maker.options[:only].should include(:index, :show, :new, :create, :edit, :update, :destroy)
      end
      
      it "is methodized" do
        maker.only.should == maker.options[:only]
      end
      
      it "has methodized setter" do
        maker.only :index, :show
        maker.only.should == [:index, :show]
      end
    end
    
    describe ":formats" do
      it "is an empty hash" do
        maker.options[:formats].should == { }
      end
      
      it "is methodized" do
        maker.formats.should === maker.options[:formats]
      end
    end
    
    describe ":parent" do
      it "is nil" do
        maker.options[:parent].should be_nil
      end
      
      it "is methodized" do
        maker.parent.should === maker.options[:parent]
      end
    end
    
    describe ":protect" do
      it "is empty by default" do
        maker.options[:protect].should be_empty
      end
      
      it "is methodized" do
        maker.protect.should === maker.options[:protect]
      end
      
      it "has methodized setter" do
        maker.protect :index, :show
        maker.protect.should == [:index, :show]
      end
    end
    
    describe ":finder" do
      it "finds all for the model" do
        mock(Article).all
        maker.options[:finder][Article, { }]
      end
    end
    
    describe ":authenticator" do
      it "finds all for the model" do
        mock(Article).all
        maker.options[:finder][Article, { }]
      end
      
      it "has a block setter" do
        fn = proc { |u, p| [u, p] }
        maker.authenticator(&fn)
        maker.authenticator[:user, :pass].should == [:user, :pass]
      end
    end
    
    describe ":credentials" do
      it "has username" do
        maker.options[:credentials][:username].should_not be_nil
      end
      
      it "has password" do
        maker.options[:credentials][:password].should_not be_nil
      end
      
      it "has realm" do
        maker.options[:credentials][:realm].should_not be_nil
      end
    end
    
    describe ":record" do
      it "loads a single record" do
        mock(Article).find_by_id(2)
        maker.options[:record][Article, { :id => 2 }]
      end
    end
  end
  
  describe "finder" do
    context "when no block is provided" do
      it "returns the finder option" do
        maker = new_maker
        maker.finder.should == maker.options[:finder]
      end
    end
    
    context "when a block is provided" do
      it "sets the finder option" do
        maker = new_maker
        block = proc { |model, params| model.find_by_id(params[:id]) }
        maker.finder(&block)
        maker.options[:finder].should == block
      end
    end
  end
  
  describe "record" do
    context "when no block is provided" do
      it "returns the record option" do
        maker = new_maker
        maker.record.should == maker.options[:record]
      end
    end
    
    context "when a block is provided" do
      it "sets the record option" do
        maker = new_maker
        block = proc { |model, params| model.find_by_id(params[:id]) }
        maker.record(&block)
        maker.options[:record].should == block
      end
    end
  end
  
  describe "prefix" do
    context "when specified as an option" do
      it "returns the option value" do
        new_maker(Article, :prefix => "posts").prefix.should == "posts"
      end
    end
    
    context "when it's not specified as an option" do
      it "returns the pluralized, downcased klass name" do
        new_maker(Article).prefix.should == "articles"
      end
      
      it "snakecases" do
        stub(klass = Class.new).name { "AwesomePerson" }
        new_maker(klass).prefix.should == 'awesome_people'
      end
    end
  end
  
  describe "parents" do
    context "when there are none" do
      it "is empty" do
        new_maker.parents.should be_empty
      end
    end
    
    context "when there is one" do
      it "includes the parent" do
        parent = new_maker(Article)
        child = new_maker(Comment, :parent => parent)
        child.parents.should == [parent]
      end
    end
    
    context "when there are many" do
      it "includes all ancestors" do
        grand_parent = new_maker(Article)
        parent = new_maker(Article, :parent => grand_parent)
        child = new_maker(Comment, :parent => parent)
        child.parents.should == [parent, grand_parent]
      end
    end
  end
  
  describe "#model" do
    it "returns an instance of Sinatra::Hat::Model" do
      maker = new_maker
      mock.proxy(Sinatra::Hat::Model.new(maker))
      maker.model
    end
  end
  
  describe "#responder" do
    it "returns an instance of Sinatra::Hat::Responder" do
      maker = new_maker
      mock.proxy(Sinatra::Hat::Responder.new(maker))
      maker.responder
    end
  end
  
  describe "generating routes" do
    it "generates routes for maker instance" do
      maker = new_maker
      router = Sinatra::Hat::Router.new(maker)
      mock.proxy(Sinatra::Hat::Router).new(maker) { router }
      mock(router).generate(maker.app)
      maker.generate_routes!
    end
  end
  
  describe "#after" do
    before(:each) do
      @maker = new_maker
    end
    
    it "takes the name of an action" do
      proc {
        maker.after(:create) { }
      }.should_not raise_error
    end
    
    it "passes a new hash mutator to the block" do
      maker.after(:create) { |arg| arg }.should be_kind_of(Sinatra::Hat::HashMutator)
    end
    
    it "lets you alter the default options" do
      maker.after(:create) do |on|
        on.success { :new_default! }
      end
      maker.responder.defaults[:create][:success][].should == :new_default!
    end
    
    describe "when there are nested resources" do
      before(:each) do
        @child_maker = new_maker(Comment)
        @child_maker.parent = @maker
      end
      
      it "mutates the child's response" do
        @child_maker.after(:create) do |on|
          on.success { :child_response }
        end
        
        @child_maker.responder.defaults[:create][:success][].should == :child_response
        @maker.responder.defaults[:create][:success].should_not === @child_maker.responder.defaults[:create][:success]
      end
    end
  end
end