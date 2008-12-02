require File.join(File.dirname(__FILE__), 'spec_helper')

describe "sinatra's hat" do
  attr_reader :hat, :model, :app
  
  before(:each) do
    @model = Class.new
    @app = Object.new
  end
  
  def new_hat(options={}, &block)
    hat = Sinatra::Hat::Maker.new(model)
    hat.define(app, options, &block)
    hat
  end
  
  it "can be instantiated" do
    proc {
      new_hat
    }.should_not raise_error
  end
  
  describe "#only" do
    it "can be specified in options hash" do
      new_hat(:only => [:create, :show]).only.should == [:create, :show]
    end
    
    it "can be specified in block" do
      new_hat { only :create, :show }.only.should == [:create, :show]
    end
    
    it "always ensures :index is last for routing purposes" do
      new_hat(:only => [:index, :show]).only.should == [:show, :index]
      new_hat(:only => [:update, :index, :show]).only.should == [:update, :show, :index]
    end
  end
  
  describe "#protected" do
    context "when there are none" do
      it "should be empty" do
        new_hat.protect.should be_empty
      end
    end
    
    context "when there are some" do
      it "can be specified in options hash" do
        new_hat(:protect => [:create, :show]).protect.should == [:create, :show]
      end
      
      it "can be specified in block" do
        new_hat { protect :create, :show }.protect.should == [:create, :show]
      end
    end
  end
  
  describe "#prefix" do
    it "returns the tableized model name" do
      stub(model).name { "Post" }
      new_hat.prefix.should == "posts"
    end
  end
end