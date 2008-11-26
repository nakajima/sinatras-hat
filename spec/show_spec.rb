require File.join(File.dirname(__FILE__), 'spec_helper')

describe Sinatra::Hat::Actions, '#show' do
  attr_reader :response, :record

  describe "show" do
    before(:each) do
      stub(Foo).first(:id => '3').returns(record)
    end
    
    it "should generate show route for json" do
      mock(record).to_json.returns(:a_result)
      mock(Foo).first(:id => '3').returns(record)
      get_it '/foos/3.json'
      response.should be_ok
    end
    
    it "should generate show route for xml" do
      mock(record).to_xml.returns(:a_result)
      mock(Foo).first(:id => '3').returns(record)
      get_it '/foos/3.xml'
      response.should be_ok
    end
    
    it "should generate show html when no format specified" do
      get_it '/foos/3'
      response.should be_ok
    end
    
    it "should return 406 when format unknown" do
      get_it '/foos/3.silly'
      response.status.should == 406
    end
  end
end