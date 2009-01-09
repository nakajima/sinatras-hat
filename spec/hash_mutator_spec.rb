require 'spec/spec_helper'

describe Sinatra::Hat::HashMutator do
  attr_reader :mutator, :hash
  
  before(:each) do
    @hash = {
      :success => proc { :ftw! },
      :failure => proc { :fail }
    }
    @mutator = Sinatra::Hat::HashMutator.new(hash)
  end
  
  it "lets you alter the success key of the passed in hash" do
    mutator.success { :pwnd! }
    hash[:success][].should == :pwnd!
  end
  
  it "lets you alter the failure key of the passed in hash" do
    mutator.failure { :pwnd! }
    hash[:failure][].should == :pwnd!
  end
end