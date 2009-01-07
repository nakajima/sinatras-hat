require 'spec/spec_helper'

describe Sinatra::Hat::Maker do
  attr_reader :model, :base

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
      @base = new_maker(Article)
    end
    
    it "has a default options hash" do
      @base.options.should_not be_nil
    end
    
    describe ":parent" do
      it "is nil" do
        base.options[:parent].should be_nil
      end
      
      it "is methodized" do
        base.parent.should === base.options[:parent]
      end
    end
    
    describe ":finder" do
      it "finds all for the model" do
        mock.proxy(Article).all
        base.options[:finder][Article, { }]
      end
    end
    
    describe ":record" do
      it "loads a single record" do
        mock.proxy(Article).first(:id => 2)
        base.options[:record][Article, { :id => 2 }]
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
end