require 'spec/spec_helper'

describe Sinatra::Hat::Resource do
  before(:each) do
    build_models!
  end
  
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
      
      it "can return path for model object" do
        @resource.path('/:id', @article).should == "/articles/#{@article.to_param}"
      end
    end
    
    context "when maker has a parent" do
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
      
      it "can return path for model object" do
        @resource.path('/:id', @comment).should == "/articles/#{@article.to_param}/comments/#{@comment.to_param}"
      end
    end
    
    context "when maker has multiple parents" do
      before(:each) do
        build_model(:replies) { integer :comment_id; belongs_to :comment }
        @reply = Reply.create! :comment => @comment
        @child = new_maker(Comment, :parent => new_maker(Article))
        @grand_child = new_maker(Reply, :parent => @child)
        @resource = Sinatra::Hat::Resource.new(@grand_child)
      end
      
      it "can return path for model object" do
        @resource.path('/:id', @reply).should == "/articles/#{@article.to_param}/comments/#{@comment.to_param}/replies/#{@reply.to_param}"
      end
    end
  end
end
