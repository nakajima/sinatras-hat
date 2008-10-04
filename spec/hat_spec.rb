require File.join(File.dirname(__FILE__), 'spec_helper')

describe "sinatra's hat" do
  attr_reader :response, :record
  before(:each) do
    @record = Object.new
    stub(@record).to_json
    stub(@record).to_xml
  end
  
  describe "default behavior" do
    it "should work as usual" do
      get_it '/'
      response.should be_ok
    end

    it "should work properly" do
      get_it '/hello/world'
      body.should == 'Hello world!'
    end
  end
  
  describe "customizing options" do
    it "should allow for custom finder" do
      mock(record).to_json
      mock(Bar).find(:all).returns(record)
      get_it '/bars.json'
      response.should be_ok
    end
    
    it "should allow new formats" do
      mock(record).attributes = { "name" => "Frank" }
      mock(record).to_yaml
      mock(record).save
      mock(Bar).find.with('3').returns(record)
      put_it '/bars/3.yaml', "bar" => { "name" => "Frank" }.to_yaml
      response.should be_ok
    end
  end
  
  describe "generating routes for model" do
    describe "index" do
      it "should generate index for foos for json" do
        mock(record).to_json
        mock(Foo).all.returns(record)
        get_it '/foos.json'
        response.should be_ok
      end

      it "should generate index for foos for xml" do
        mock(record).to_xml
        mock(Foo).all.returns(record)
        get_it '/foos.xml'
        response.should be_ok
      end
      
      it "should return 400 when format omitted" do
        get_it '/foos'
        response.status.should == 400
      end
      
      it "should return 406 when format unknown" do
        get_it '/foos.bars'
        response.status.should == 406
      end
    end

    describe "show" do
      it "should generate show route for json" do
        mock(record).to_json
        mock(Foo).find.with('3').returns(record)
        get_it '/foos/3.json'
        response.should be_ok
      end
      
      it "should generate show route for xml" do
        mock(record).to_xml
        mock(Foo).find.with('3').returns(record)
        get_it '/foos/3.xml'
        response.should be_ok
      end
      
      it "should return 406 when format unknown" do
        get_it '/foos/3.silly'
        response.status.should == 406
      end
    end
    
    describe "create" do
      it "should create a record via json" do
        mock(record).attributes = { "name" => "Frank" }
        mock(record).to_json
        mock(record).save
        mock(Foo).new.returns(record)
        post_it '/foos.json', "foo" => { "name" => "Frank" }.to_json
        response.should be_ok
      end
      
      it "should create a record via xml" do
        mock(record).attributes = { "name" => "Frank" }
        mock(record).to_xml
        mock(record).save
        mock(Foo).new.returns(record)
        post_it '/foos.xml', "foo" => FOO_XML
        response.should be_ok
      end
      
      it "should return 400 when format omitted" do
        post_it '/foos', "foo" => FOO_XML
        response.status.should == 400
      end
      
      it "should return 406 when format unknown" do
        post_it '/foos.silly', "foo" => FOO_XML
        response.status.should == 406
      end
    end
    
    describe "update" do
      it "should update a record via json" do
        mock(record).attributes = { "name" => "Frank" }
        mock(record).to_json
        mock(record).save
        mock(Foo).find.with('3').returns(record)
        put_it '/foos/3.json', "foo" => { "name" => "Frank" }.to_json
        response.should be_ok
      end
      
      it "should update a record via xml" do
        mock(record).attributes = { "name" => "Frank" }
        mock(record).to_xml
        mock(record).save
        mock(Foo).find.with('3').returns(record)
        put_it '/foos/3.xml', "foo" => FOO_XML
        response.should be_ok
      end
      
      it "should return 400 when format omitted" do
        put_it '/foos/3', "foo" => FOO_XML
        response.status.should == 400
      end
      
      it "should return 406 when format unknown" do
        put_it '/foos/3.silly', "foo" => FOO_XML
        response.status.should == 406
      end
    end
    
    describe "destroy" do
      it "should destroy a record" do
        mock(record).destroy
        mock(Foo).find('3').returns(record)
        delete_it '/foos/3'
        response.should be_ok
      end
    end
  end
end