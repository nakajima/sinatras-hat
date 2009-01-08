require 'spec/spec_helper'

describe Sinatra::Hat::Model do
  attr_reader :model, :maker, :fake_request
  
  def new_model(maker=new_maker)
    Sinatra::Hat::Model.new(maker)
  end
  
  describe "initialization" do
    it "takes an instance of Maker" do
      proc {
        maker = new_maker
        new_model(maker)
      }.should_not raise_error
    end
  end
  
  describe "all()" do
    before(:each) do
      @maker = new_maker
      @model = new_model(maker)
    end
    
    it "takes the params" do
      proc {
        model.all({ })
      }.should_not raise_error
    end
    
    it "calls the finder" do
      mock.proxy(maker.options[:finder]).call(Article, { })
      model.all({ }).should == [:first_article, :second_article]
    end
  end
  
  describe "find()" do
    before(:each) do
      @maker = new_maker
      @model = new_model(maker)
    end
    
    it "takes the params" do
      proc {
        model.find({ })
      }.should_not raise_error
    end
    
    it "calls for the :record" do
      mock.proxy(maker.options[:record]).call(Article, { :id => 2 })
      model.find(:id => 2).should == :article
    end
  end
  
  describe "plural" do
    it "returns snakecased, pluralized form of model name" do
      new_model(new_maker(Article)).plural.should == "articles"
    end
  end
  
  describe "singular" do
    it "returns snakecased, singular form of model name" do
      new_model(new_maker(Article)).singular.should == "article"
    end
  end
  
  describe "new" do
    context "when there is no parent" do
      it "instantiates a new model object" do
        mock.proxy(Article).new(anything)
        new_model.new
      end
      
      it "railsifies params passed through" do
        mock.proxy(Article).new("name" => "The article")
        new_model.new("article[name]" => "The article")
      end
    end
    
    context "when there is a parent" do
      attr_reader :article
      
      before(:each) do
        @article = Article.new
        @maker = new_maker(Article)
        @maker.setup(mock_app)
        stub(maker.model).find(anything) { @article }
      end
      
      context "when there is an association proxy" do
        it "uses the association proxy" do
          mock(comments_proxy = []).new(anything)
          mock.proxy(article).comments { comments_proxy }
          new_model(maker.mount(Comment)).new
        end
      end

      context "when there isn't an association proxy" do
        it "just returns the klass" do
          mock.proxy(Comment).new(anything)
          mock.proxy(article).respond_to?("comments") { false }
          new_model(maker.mount(Comment)).new
        end
      end
    end
  end
end
