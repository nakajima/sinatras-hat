require File.join(File.dirname(__FILE__), 'spec_helper')

describe Sinatra::Hat::Actions, '#new' do
  attr_reader :response, :new_foo

  before(:each) do
    @new_foo = Object.new
    stub(new_foo).hello { "The new foo" }
    stub(Foo).new.returns { new_foo }
  end

  it "should generate new action" do
    get_it '/foos/new'
    response.should be_ok
  end

  it "assigns a new model object" do
    mock(new_foo).hello
    get_it '/foos/new'
  end

  it "should render proper view template" do
    get_it '/foos/new'
    body.should == "The new foo"
  end

  it "should return 406 when format unknown" do
    get_it '/foos/new.bars'
    response.status.should == 406
  end
end