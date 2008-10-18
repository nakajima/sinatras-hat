require File.join(File.dirname(__FILE__), 'spec_helper')

describe "sinatra's hat" do
  attr_reader :response, :record
  before(:each) do
    @response = nil
    @record = Object.new
    stub(@record).id.returns(3)
    stub(@record).name.returns("Frank")
    stub(@record).to_json.returns(:a_result)
    stub(@record).to_xml.returns(:a_result)
    stub(Foo).first(:id => '3').returns(@record)
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
    before(:each) do
      stub(Bar).find(anything).returns(record)
    end
    
    it "should allow for custom finder" do
      mock(Bar).find(:all).returns(record)
      record.should respond_to(:to_json)
      get_it '/bars.json'
      response.should be_ok
    end
    
    it "should serialize into new formats" do
      mock(record).name.returns("Frank")
      get_it '/bars/3.html'
      response.should be_ok
      body.should == "<h1>Frank</h1>"
    end
    
    it "should allow custom loader" do
      mock(Bar).find('3').returns(record)
      get_it '/bars/3.json'
      response.should be_ok
    end
    
    describe ":only option" do
      it "should take a symbol" do
        stub(Fizz).all.returns(record)
        get_it '/fizzs.json'
        response.should be_ok
        get_it '/fizzs/1.json'
        response.status.should == 404
      end
      
      it "should take an array" do
        stub(Buzz).all.returns(record)
        stub(Buzz).first(:id => '3').returns(record)
        
        get_it '/buzzs.json'
        response.should be_ok
        
        get_it '/buzzs/3.json'
        response.should be_ok
        
        put_it '/buzzs/3.json', "buzz" => { "whiz" => "bang" }.to_json
        response.status.should == 404
      end
    end
    
    describe "protecting actions" do
      it "uses basic auth if action is protected" do
        get_it '/sekrets'
        response.status.should == 401
      end
      
      it "allows access when proper credentials provided" do
        mock(Sekret).all.returns([])
        
        get_it '/sekrets.json', :env => {
          'HTTP_AUTHORIZATION' => 'Basic ' + ["spec:helper"].pack("m*")
        }
        
        response.should be_ok
      end
      
      it "denies access when incorrect credentials provided" do
        get_it '/sekrets.json', :env => {
          'HTTP_AUTHORIZATION' => 'Basic ' + ["wrong:stuff"].pack("m*")
        }
        
        response.status.should == 401
      end
      
      it "allows non-protected actions" do
        mock(Sekret).first(:id => '1').returns(record)
        get_it '/sekrets/1.json'
        response.should be_ok
      end
      
      it "allows :all option for protect" do
        get_it '/top_sekrets'
        response.status.should == 401
      end
    end
  end
  
  describe "generating routes for model" do
    before(:each) do
      stub(Foo).all.returns([record])
      stub(Foo).first.returns(record)
    end
    
    describe "index" do
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
    
    describe "create" do
      it "should create a record via json" do
        mock(record).attributes = { "name" => "Frank" }
        mock(record).to_json.returns(:a_result)
        mock(record).save
        mock(Foo).new.returns(record)
        post_it '/foos.json', "foo" => { "name" => "Frank" }.to_json
        response.should be_ok
      end
      
      it "should create a record via xml" do
        mock(record).attributes = { "name" => "Frank" }
        mock(record).to_xml.returns(:a_result)
        mock(record).save
        mock(Foo).new.returns(record)
        post_it '/foos.xml', "foo" => FOO_XML
        response.should be_ok
      end
      
      it "should update a record via yaml" do
        mock(record).attributes = { "name" => "Frank" }
        mock(record).to_yaml.returns(:a_result)
        mock(record).save
        mock(Foo).new.returns(record)
        post_it '/foos.yaml', "foo" => { "name" => "Frank" }.to_yaml
        response.should be_ok
      end
      
      it "should update a record using regular url params" do
        mock(record).attributes = { "name" => "Frank" }
        mock(record).save
        mock(Foo).new.returns(record)
        post_it '/foos', "foo[name]" => "Frank"
        response.should be_redirection
      end
      
      it "should return 406 when format unknown" do
        post_it '/foos.silly', "foo" => FOO_XML
        response.status.should == 406
      end
    end
    
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
    
    describe "destroy" do
      it "should destroy a record" do
        mock(record).destroy
        mock(Foo).first(:id => '3').returns(record)
        delete_it '/foos/3'
        response.should be_ok
      end
    end
  end
  
  describe "nesting routes" do
    it "should description" do
      
    end
  end
end