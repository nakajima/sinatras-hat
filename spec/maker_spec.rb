require File.join(File.dirname(__FILE__), 'spec_helper')

describe "sinatra's hat" do
  attr_reader :hat, :app, :child, :maker, :model, :child_klass, :grand_child_klass
  
  before(:each) do
    @app = Object.new
    @model = Class.new
    @grand_child_klass = Class.new
    @child_klass = Class.new
    stub(model).name { "Post" }
    stub(child_klass).name { "Comment" }
  end
  
  def new_maker(options={}, &block)
    hat = Sinatra::Hat::Maker.new(model)
    hat.define(app, options, &block)
    hat
  end
  
  it "can be instantiated" do
    proc {
      new_maker
    }.should_not raise_error
  end
  
  describe "#only" do
    it "can be specified in options hash" do
      new_maker(:only => [:create, :show]).only.should == [:create, :show]
    end
    
    it "can be specified in block" do
      new_maker { only :create, :show }.only.should == [:create, :show]
    end
    
    it "always ensures :index is last for routing purposes" do
      new_maker(:only => [:index, :show]).only.should == [:show, :index]
      new_maker(:only => [:update, :index, :show]).only.should == [:update, :show, :index]
    end
  end
  
  describe "#authenticator" do
    it "defaults to checking username and password" do
      maker = new_maker do
        credentials[:username] = :user
        credentials[:password] = :pass
      end
      
      maker.authenticator.call(:user, :pass).should be_true
      maker.authenticator.call(:wrong, :nogood).should be_false
    end
    
    it "can be overridden with custom authenticator" do
      mock(checker = Object.new).call!(:user, :pass)
      
      maker = new_maker do
        authenticator do |username, password|
          checker.call!(username, password)
        end
      end
      
      maker.authenticator.call(:user, :pass)
    end
  end
  
  describe "#protected" do
    context "when there are none" do
      it "should be empty" do
        new_maker.protect.should be_empty
      end
    end
    
    context "when there are some" do
      it "can be specified in options hash" do
        new_maker(:protect => [:create, :show]).protect.should == [:create, :show]
      end
      
      it "can be specified in block" do
        new_maker { protect :create, :show }.protect.should == [:create, :show]
      end
    end
  end
  
  describe "#mount" do
    attr_reader :child_klass
    
    before(:each) do
      @maker = new_maker
    end
    
    it "returns a new instance of Maker" do
      maker.mount(child_klass).should be_kind_of(Sinatra::Hat::Maker)
    end
    
    it "should set self as the parent" do
      maker.mount(child_klass).parent.should == maker
    end
  end
  
  describe "#parents" do
    before(:each) do
      @maker = new_maker
    end
    
    context "when there are no parents" do
      it "is empty" do
        maker.parents.should be_empty
      end
    end
    
    context "when there is one parent" do
      it "returns the one parent" do
        maker.mount(child_klass).parents.should == [maker]
      end
    end
    
    context "when there are many parents" do
      it "returns all the parents" do
        child = maker.mount(child_klass)
        grand_child = child.mount(grand_child_klass)
        grand_child.parents.should == [child, maker]
      end
    end
    it "should set self as the parent" do
      maker.mount(child_klass).parent.should == maker
    end
  end
  
  describe "#proxy" do
    context "when there's no parent" do
      it "returns the model" do
        new_maker.proxy.should == model
      end
    end
    
    context "when there is a parent" do
      before(:each) do
        @maker = new_maker
        @child = maker.mount(child_klass)
      end
      
      context "with an association proxy" do
        it "returns the association proxy" do
          mock(model).first(:id => :foo) do
            mock(comments_proxy = Object.new).comments { :comments_proxy }
            comments_proxy
          end

          child.proxy(:post_id => :foo).should == :comments_proxy
        end
      end
      
      context "without an association proxy" do
        it "returns the model" do
          mock(model).first(:id => :foo) { Object.new }

          child.proxy(:post_id => :foo).should == child_klass
        end
      end
    end
  end
  
  describe "path helpers" do
    describe "#prefix" do
      it "returns the tableized model name" do
        new_maker.prefix.should == "posts"
      end
    end

    describe "#resource_path" do
      context "with no parent" do
        it "returns normal resource path" do
          new_maker.resource_path('/:id').should == "/posts/:id"
        end
        
        it "can return :root path" do
          new_maker.resource_path('/').should == "/posts"
        end
      end
      
      context "with parents" do
        it "returns nested resource path" do
          child = new_maker.mount(child_klass)
          child.resource_path('/:id').should == "/posts/:post_id/comments/:id"
        end
        
        it "doesn't change parents" do # regression test
          child = new_maker.mount(child_klass)
          child.resource_path('/:id').should == "/posts/:post_id/comments/:id"
          child.resource_path('/:id').should == "/posts/:post_id/comments/:id"
        end
      end
      
      describe "#model_id" do
        it "returns parent param value" do
          new_maker.model_id.should == :post_id
        end
      end
    end
  end
end