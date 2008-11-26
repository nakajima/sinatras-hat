require File.join(File.dirname(__FILE__), 'spec_helper')

describe Sinatra::Hat::Actions, '#index' do
  attr_reader :response, :record

  before(:each) do
    stub(Foo).all.returns([record])
    stub(Foo).first.returns(record)
  end

  it "should generate index for foos for json" do
    mock(record).to_json.returns(:a_result)
    mock(Foo).all.returns(record)
    get_it '/foos.json'
    response.should be_ok
  end

  it "should generate index for foos for xml" do
    mock(record).to_xml.returns(:a_result)
    mock(Foo).all.returns(record)
    get_it '/foos.xml'
    response.should be_ok
  end

  it "should generate index for foos for html" do
    get_it '/foos'
    response.should be_ok
  end

  it "should render proper view template" do
    get_it '/foos'
    body.should == "Frank"
  end

  it "should return 406 when format unknown" do
    get_it '/foos.bars'
    response.status.should == 406
  end
end