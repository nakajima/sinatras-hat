require 'spec/spec_helper'

describe Sinatra::Hat::Responder do
  attr_reader :maker, :responder
  
  def new_responder(maker=@maker)
    Sinatra::Hat::Responder.new(maker)
  end
  
  before(:each) do
    @maker = new_maker
  end
  
  describe "initialization" do
    it "takes an instance of Maker" do
      proc {
        Sinatra::Hat::Responder.new(@maker)
      }.should_not raise_error
    end
  end
  
  describe "success" do
    context "when there's a format" do
      it "serializes the response" do
        request = fake_request(:format => "yaml")
        mock.proxy(responder = new_responder).serialize(request, :article)
        responder.success(:show, request, :article)
      end
    end
    
    context "when there's no format" do
      it "calls that action's :success proc" do
        request = fake_request
        mock.proxy(Sinatra::Hat::Response).new(maker, request) do |response|
          mock.proxy(response).render(anything)
        end
        new_responder.success(:show, request, :article)
      end
    end
    
    describe "assigning instance variables" do
      context "when the result is a collection" do
        it "assigns the plural instance variable in the request" do
          request = fake_request
          new_responder.success(:index, request, [:articles])
          request.instance_eval { @articles }.should == [:articles]
        end
      end
      
      context "when the result is not a collection" do
        it "assigns the singular instance variable in the request" do
          request = fake_request
          new_responder.success(:show, request, :article)
          request.instance_eval { @article }.should == :article
        end
      end
    end
  end
  
  describe "not_found" do
    it "calls not_found on the request" do
      mock(request = fake_request).not_found
      new_responder.not_found(request)
    end
  end
  
  describe "failure" do
    # context "when there's a format" do
    #   it "serializes the response" do
    #     request = fake_request(:format => "yaml")
    #     mock.proxy(responder = new_responder).serialize("yaml", :article)
    #     responder.success(:show, request, :article)
    #   end
    # end
    
    context "when there's no format" do
      it "calls that action's :failure proc" do
        request = fake_request
        mock.proxy(Sinatra::Hat::Response).new(maker, request) do |response|
          mock(response).redirect(anything)
        end
        new_responder.failure(:show, request, :article)
      end
    end
  end
  
  describe "serialize()" do
    before(:each) do
      @responder = new_responder
    end
    
    context "when there is no formatter" do
      context "when the data responds to to_*" do
        it "calls to_* on the data" do
          responder.serialize(fake_request(:format => "yaml"), [:article]).should == [:article].to_yaml
        end
      end

      context "when the data doesn't respond to to_*" do
        it "returns a 406 error code for the response" do
          mock(bad_request = fake_request(:format => "say_what")).error(406)
          responder.serialize(bad_request, [:article])
        end
      end
    end
    
    context "when there is a formatter" do
      before(:each) do
        maker.formats[:ruby] = proc { |data| [data, :formatted].inspect }
      end
      
      it "calls the formatter, passing the data" do
        responder.serialize(fake_request(:format => "ruby"), :article).should == [:article, :formatted].inspect
      end
    end
  end
  
  describe "custom responses using #on" do
    before(:each) do
      @responder = new_responder
    end
  end
end
