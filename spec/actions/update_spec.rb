require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Sinatra::Hat::Actions, '#update' do
  attr_reader :response, :record

  describe "update" do
    it "should update a record via json" do
      mock(record).attributes = { "name" => "Frank" }
      mock(record).to_json.returns(:a_result)
      mock(record).save
      mock(Foo).first(:id => '3').returns(record)
      put_it '/foos/3.json', "foo" => { "name" => "Frank" }.to_json
      response.should be_ok
    end
    
    it "should update a record via xml" do
      mock(record).attributes = { "name" => "Frank" }
      mock(record).to_xml.returns(:a_result)
      mock(record).save
      mock(Foo).first(:id => '3').returns(record)
      put_it '/foos/3.xml', "foo" => FOO_XML
      response.should be_ok
    end
    
    it "should update a record via yaml" do
      mock(record).attributes = { "name" => "Frank" }
      mock(record).to_yaml.returns(:a_result)
      mock(record).save
      put_it '/foos/3.yaml', "foo" => { "name" => "Frank" }.to_yaml
      response.should be_ok
    end
    
    it "should update a record using regular url params" do
      mock(record).attributes = { "name" => "Frank" }
      mock(record).save
      put_it '/foos/3', "foo[name]" => "Frank"
      response.should be_redirection
    end
    
    it "should return 406 when format unknown" do
      put_it '/foos/3.silly', "foo" => FOO_XML
      response.status.should == 406
    end
  end
end