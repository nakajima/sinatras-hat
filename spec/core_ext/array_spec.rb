require File.dirname(__FILE__) + '/../spec_helper'

describe Array, 'extensions' do
  attr_reader :array
  
  before(:each) do
    @array = [:foo, :bar, :fizz, :buzz]
  end
  
  describe "extract_options!" do
    context "when there are none" do
      it "returns an empty hash" do
        options = array.extract_options!
        options.should == { }
      end
    end
    
    context "when there are some" do
      before(:each) do
        array << { :whammy => :bar }
      end
      
      it "returns the options" do
        options = array.extract_options!
        options.should == { :whammy => :bar }
      end
      
      it "removes the options from the array" do
        options = array.extract_options!
        array.should_not include(options)
      end
    end
  end
  
  describe "#move_to_front" do
    context "when the entries are in the array" do
      it "moves entries to front" do
        array.move_to_front(:fizz, :buzz)
        array.should == [:buzz, :fizz, :foo, :bar]
      end
    end
    
    context "when the entries aren't in the array" do
      it "leaves the array alone" do
        array.move_to_front(:whammy)
        array.should == [:foo, :bar, :fizz, :buzz]
      end
    end
  end
  
  describe "#move_to_back" do
    context "when the entries are in the array" do
      it "moves entries to front" do
        array.move_to_back(:foo, :bar)
        array.should == [:fizz, :buzz, :foo, :bar]
      end
    end
    
    context "when the entries aren't in the array" do
      it "leaves the array alone" do
        array.move_to_front(:whammy)
        array.should == [:foo, :bar, :fizz, :buzz]
      end
    end
  end
end