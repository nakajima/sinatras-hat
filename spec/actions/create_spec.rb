require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Sinatra::Hat::Actions, '#create' do
  attr_reader :response, :record

  describe "create" do
    it "should create a record via json" do
      mock(record).attributes = { "name" => "Frank" }
      mock(record).to_json.returns(:a_result)
      mock(record).save.returns(true)
      mock(Foo).new.returns(record)
      post_it '/foos.json', "foo" => { "name" => "Frank" }.to_json
      response.should be_ok
    end
    
    it "should create a record via xml" do
      mock(record).attributes = { "name" => "Frank" }
      mock(record).to_xml.returns(:a_result)
      mock(record).save.returns(true)
      mock(Foo).new.returns(record)
      post_it '/foos.xml', "foo" => FOO_XML
      response.should be_ok
    end
    
    it "should create a record via yaml" do
      mock(record).attributes = { "name" => "Frank" }
      mock(record).to_yaml.returns(:a_result)
      mock(record).save.returns(true)
      mock(Foo).new.returns(record)
      post_it '/foos.yaml', "foo" => { "name" => "Frank" }.to_yaml
      response.should be_ok
    end
    
    it "should create a record using regular url params" do
      mock(record).attributes = { "name" => "Frank" }
      mock(record).save.returns(true)
      mock(Foo).new.returns(record)
      post_it '/foos', "foo[name]" => "Frank"
      response.should be_redirection
    end
    
    it "should return 406 when format unknown" do
      post_it '/foos.silly', "foo" => FOO_XML
      response.status.should == 406
    end
  end
end