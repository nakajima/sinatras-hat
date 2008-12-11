require File.join(File.dirname(__FILE__), 'spec_helper')

describe Sinatra::Hat::Action do
  attr_reader :app, :model, :maker, :action, :handler, :event
  
  before(:each) do
    @app = Object.new
    @model = Class.new
    @maker = Sinatra::Hat::Maker.new(model)
  end
  
  describe "basics" do
    before(:each) do
      @handler = proc { |record| erb "/posts/#{record.id}" }
      @action = Sinatra::Hat::Action.new(maker, handler)
    end
    
    it "has a maker" do
      action.maker.should == maker
    end

    it "has a handler" do
      action.handler.should == handler
    end
  end
  
  describe "event handling" do
    before(:each) do
      @handler = proc { |params| params[:foo] }
      @action = Sinatra::Hat::Action.new(maker, handler)
      @event = Object.new
      stub(event).params.returns({ :foo => "bar" })
    end
    
    it "receives an event" do
      proc {
        action.handle(event)
      }.should_not raise_error
    end
    
    it "passes the event params" do
      mock(event).params.returns(:foo => "bar")
      mock(handler)[{ :foo => "bar" }]
      action.handle(event)
    end
    
    it "returns the result of the handler" do
      action.handle(event).should == "bar"
    end
  end
  
end