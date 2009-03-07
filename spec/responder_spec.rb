require 'spec/spec_helper'

describe Sinatra::Hat::Responder do
  attr_reader :maker, :responder
  
  def new_responder(maker=@maker)
    Sinatra::Hat::Responder.new(maker)
  end
  
  before(:each) do
    build_models!
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
    context "when there's a default format" do
      before(:each) do
        @maker.format :json
      end
      
      it 'serializes the response with the default format' do
        request = fake_request
        responder = new_responder
        responder.success(:show, request, :article).should == :article.to_json
      end
    end
    
    context "when there's a format" do
      it "serializes the response" do
        request = fake_request(:format => "yaml")
        mock.proxy(responder = new_responder).serialize(:article, "yaml")
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
      
      describe "assigning parent instance variables" do
        before(:each) do
          @parent_maker = new_maker(Article)
          @child_maker = new_maker(Comment)
          @responder = @child_maker.responder
        end
      end
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
        it "serializes data and gets mime type" do
          response, mime = responder.serialize([:article], "yaml")
          response.should == [:article].to_yaml
          mime.should == 'text/yaml'
        end
      end

      context "when the data doesn't respond to to_*" do
        it "returns nil" do
          responder.serialize([:article], "say_what").should be_nil
        end
      end
    end
    
    context "when there is a formatter" do
      before(:each) do
        maker.formats[:yaml] = proc { |data| [data, :formatted].inspect }
      end
      
      it "returns serialized data and the mime type" do
        response = responder.serialize(:article, "yaml")
        response.should == [[:article, :formatted].inspect, 'text/yaml']
      end
    end
  end
  
  describe "custom responses using #on" do
    before(:each) do
      @responder = new_responder
    end
  end
end
