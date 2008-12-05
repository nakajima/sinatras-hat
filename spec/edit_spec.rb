require File.join(File.dirname(__FILE__), 'spec_helper')

describe Sinatra::Hat::Actions, '#edit' do
  attr_reader :response, :record

  before(:each) do
    stub(record).name { "EDIT A FOO" }
    stub(Foo).first(:id => '3').returns(record)
  end
  
  it "should generate edit route" do
    get_it '/foos/3/edit'
    response.should be_ok
  end
  
  it "renders edit template" do
    get_it '/foos/3/edit'
    response.body.should == "EDIT A FOO"
  end
end