require 'spec/spec_helper'

describe Sinatra::Hat::Model do
  attr_reader :model, :maker, :fake_request
  
  describe "initialization" do
    it "takes an instance of Maker" do
      proc {
        maker = new_maker
        Sinatra::Hat::Model.new(maker)
      }.should_not raise_error
    end
  end
  
  describe "all()" do
    before(:each) do
      @maker = new_maker
      @model = Sinatra::Hat::Model.new(maker)
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
end
