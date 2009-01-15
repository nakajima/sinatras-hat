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
      model.all({ }).should == Article.all
    end
  end
  
  describe "foreign_key" do
    before(:each) do
      @maker = new_maker
      @model = new_model(maker)
    end
    
    it "returns the singular name with _id" do
      model.foreign_key.should == "#{model.singular}_id".to_sym
    end
  end
  
  describe "find_owner" do
    before(:each) do
      @maker = new_maker
      @model = new_model(maker)
    end
    
    it "uses the foreign key to search the params" do
      model.find_owner(model.foreign_key => @article.to_param).should == @article
    end
  end
  
  describe "find()" do
    attr_reader :article
    
    before(:each) do
      @maker = new_maker
      @model = new_model(maker)
    end
    
    it "takes the params" do
      proc {
        model.find(:id => @article.to_param)
      }.should_not raise_error
    end
    
    it "calls for the :record" do
      mock.proxy(maker.options[:record]).call(Article, { :id => @article.to_param })
      model.find(:id => @article.to_param).should == @article
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
  
  describe "update" do
    it "finds the record" do
      model = new_model
      mock.proxy(model).find(anything) { @article }
      mock.proxy(@article).attributes = { "name" => "Hooray!" }
      model.update("id" => @article.to_param, "article[name]" => "Hooray!")
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
        @maker = new_maker(Article)
        @maker.setup(mock_app)
        child_maker = maker.mount(Comment)
        child_maker.parent = maker
        @child_model = new_model(child_maker)
      end
      
      context "when there is an association proxy" do
        it "uses the association proxy" do
          @child_model.new(:article_id => @article.to_param)
        end
      end

      context "when there isn't an association proxy" do
        it "just returns the klass" do
          mock.proxy(Comment).new(anything)
          new_model(maker.mount(Comment)).new
        end
      end
    end
  end
end
