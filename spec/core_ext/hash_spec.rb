require File.dirname(__FILE__) + '/../spec_helper'

describe Hash, 'extensions' do
  describe "#nest!" do
    attr_reader :params
    
    before(:each) do
      @params = {
        "post[name]" => "The Name",
        "post[body]" => "The body"
      }
      
      @params.nest!
    end
    
    it "fakes railsy params" do
      params["post"].should_not be_nil
      params["post"]["name"].should == "The Name"
      params["post"]["body"].should == "The body"
    end
    
    it "has indifferent access" do
      params[:post].should_not be_nil
      params[:post][:name].should == "The Name"
      params[:post][:body].should == "The body"
    end
  end
end