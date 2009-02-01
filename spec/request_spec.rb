require 'spec/spec_helper'

describe Sinatra::Hat::Request do
  def new_request(request=fake_request, action=:show)
    Sinatra::Hat::Request.new(request, action)
  end
  
  describe "perform!" do
    it "instance_exec's the handler block, passing the request" do
      Sinatra::Hat::Maker.actions[:show] = { :fn => proc { |r| called_with(r); set :result, :ok } }
      
      sinatra_request = fake_request
      
      request = new_request(sinatra_request)
      
      mock(request).called_with(sinatra_request)
      mock.proxy(request).instance_exec(sinatra_request)
      
      request.perform!
    end
    
    it "calls not_found when result is nil" do
      Sinatra::Hat::Maker.actions[:show] = { :fn => proc { set :result, nil } }
      mock(sinatra_request = fake_request).not_found
      new_request(sinatra_request).perform!
    end
  end
  
  describe "#set" do
    it "sets the attr value" do
      request = new_request
      request.set(:result, :the_result)
      request.result.should == :the_result
    end
  end
  
  describe "setting cache headers" do
    # This feels a bit awkard still...
    describe "#set_last_modified" do
      describe "for show" do
        before(:each) do
          @sinatra_request = fake_request
          @request = new_request(@sinatra_request, :show)
          @request.set :result, :article
        end
        
        it "sets last_modified to results of cache header definition" do
          Sinatra::Hat::Request.cache_header_definitions[:show][:last_modified] = proc { :the_result }
          mock(@sinatra_request).last_modified(:the_result)
          @request.set_last_modified(:some_model)
        end

        it "passes the model, params, and result" do
          Sinatra::Hat::Request.cache_header_definitions[:show][:last_modified] = proc { |*a| a }
          mock(@sinatra_request).last_modified([:some_model, { }])
          @request.set_last_modified(:some_model)
        end        
      end
      
      describe "for index" do
        before(:each) do
          @sinatra_request = fake_request
          @request = new_request(@sinatra_request, :index)
          @request.set :result, [:article]
        end
        
        it "sets last_modified to results of cache header definition" do
          Sinatra::Hat::Request.cache_header_definitions[:index][:last_modified] = proc { :the_result }
          mock(@sinatra_request).last_modified(:the_result)
          @request.set_last_modified(:some_model)
        end

        it "passes the model, params, and result" do
          Sinatra::Hat::Request.cache_header_definitions[:index][:last_modified] = proc { |*a| a }
          mock(@sinatra_request).last_modified([:some_model, { }])
          @request.set_last_modified(:some_model)
        end        
      end
    end
  end
end