require File.join(File.dirname(__FILE__), 'spec_helper')

describe "functional specs" do
  attr_reader :response, :record

  before(:each) do
    @response = nil
    @record = Object.new
    stub(record).id.returns(3)
    stub(record).name.returns("Frank")
    stub(record).to_json.returns(:a_result)
    stub(record).to_xml.returns(:a_result)
    stub(Foo).first(:id => '3').returns(record)
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
  
  describe "when templates aren't found" do
    before(:each) do
      stub(Fizz).all { [] }
    end
    
    it "returns thoughtful error message" do
      get_it '/fizzs'
      response.should be_ok
      response.body.should include("There was a problem with your view template:")
      response.body.should include("index.erb")
    end
  end
end

