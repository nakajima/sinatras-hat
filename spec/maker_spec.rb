require 'spec/spec_helper'

describe Sinatra::Hat::Maker do
  attr_reader :model, :maker

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
  
  it "has a klass" do
    new_maker(Article).klass.should == Article
  end
  
  describe "default options" do
    before(:each) do
      @maker = new_maker(Article)
    end
    
    it "has a default options hash" do
      maker.options.should_not be_nil
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
    
    describe ":finder" do
      it "finds all for the model" do
        mock.proxy(Article).all
        maker.options[:finder][Article, { }]
      end
    end
    
    describe ":record" do
      it "loads a single record" do
        mock.proxy(Article).first(:id => 2)
        maker.options[:record][Article, { :id => 2 }]
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
  
  describe "actions" do
    attr_reader :maker, :request, :app
    
    describe "#handle_index" do
      before(:each) do
        mock_app {  }
        @maker = new_maker(Article)
        stub(@request = Object.new).params.returns({ })
      end
      
      it "takes a request" do
        maker.handle_index(request)
      end
      
      it "loads all records" do
        mock.proxy(maker.model).all(anything) { [] }
        maker.handle_index(request)
      end
      
      it "assigns the proper instance variable in the request" do
        maker.handle_index(request)
        request.instance_eval { @articles }.should == [:first_article, :second_article]
      end

      describe "rendering a response" do
        context "when there's a :format param" do
          before(:each) do
            stub(@request = Object.new).params.returns(:format => "yaml")
            stub(maker.model).all(anything).returns([:article])
          end
          
          it "serializes the data in the appropriate format" do
            mock.proxy(maker.responder).serialize([:article], :format => "yaml")
            maker.handle_index(request)
          end
        end
        
        context "when there's no :format param" do
          it "renders a view" do
            pending "not there yet."
          end
        end
      end
    end
  end
end