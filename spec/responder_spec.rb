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
  
  describe "serialize()" do
    before(:each) do
      @responder = new_responder
    end
    
    context "when there is no formatter" do
      it "calls to_* on the data" do
        responder.serialize([:article], fake_request(:format => "yaml")).should == [:article].to_yaml
      end
    end
    
    context "when there is a formatter" do
      before(:each) do
        maker.formats[:yaml] = proc { |data| [data, :formatted] }
      end
      
      it "calls the formatter, passing the data" do
        responder.serialize(:article, fake_request(:format => "yaml")).should == [:article, :formatted]
      end
    end
  end
  
  describe "render()" do
    before(:each) do
      @responder = new_responder
    end
    
    describe "assigning instance variables" do
      context "when the result is a collection" do
        it "assigns the plural instance variable in the request" do
          request = fake_request
          responder.render(:index, :request => request, :data => [:articles])
          request.instance_eval { @articles }.should == [:articles]
        end
      end
      
      context "when the result is not a collection" do
        it "assigns the singular instance variable in the request" do
          request = fake_request
          responder.render(:show, :request => request, :data => :article)
          request.instance_eval { @article }.should == :article
        end
      end
    end
    
    describe "rendering templates" do
      it "renders the index template" do
        request = fake_request
        mock.proxy(request).erb(:index, :views_directory => fixture('views/articles'))
        responder.render(:index, :request => request, :data => [:articles])
      end
      
      it "renders the show template" do
        request = fake_request
        mock.proxy(request).erb(:show, :views_directory => fixture('views/articles'))
        responder.render(:show, :request => request, :data => :article)
      end
    end
  end
end
