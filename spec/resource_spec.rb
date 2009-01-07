require 'spec/spec_helper'

describe Sinatra::Hat::Resource do
  describe "initialization" do
    it "takes an instance of Maker" do
      proc {
        Sinatra::Hat::Resource.new(new_maker)
      }.should_not raise_error
    end
  end
  
  describe "paths" do
    context "when maker has no parent" do
      before(:each) do
        maker = new_maker(Article)
        @resource = Sinatra::Hat::Resource.new(maker)
      end
      
      it "returns normal resource path" do
        @resource.path('/:id').should == "/articles/:id"
      end
      
      it "can return :root path" do
        @resource.path('/:id').should == "/articles/:id"
      end
    end
    
    context "when maker has parents" do
      before(:each) do
        @child = new_maker(Comment, :parent => new_maker(Article))
        @resource = Sinatra::Hat::Resource.new(@child)
      end
      
      it "returns nested resource path" do
        @resource.path('/:id').should == "/articles/:article_id/comments/:id"
      end
      
      it "doesn't mutate parents" do # regression test
        @resource.path('/:id').should == "/articles/:article_id/comments/:id"
        @resource.path('/:id').should == "/articles/:article_id/comments/:id"
      end
    end
  end
end
