require 'spec/spec_helper'

describe Sinatra::Hat::Model do
  attr_reader :model, :maker, :fake_request
  
  def new_model(maker)
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
end
