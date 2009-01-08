require 'spec/spec_helper'

describe Sinatra::Hat::Extendor do
  describe "mount" do
    it "takes a klass" do
      proc {
        mock_app { mount(Article) }
      }.should_not raise_error
    end
    
    it "takes an options hash" do
      proc {
        mock_app { mount(Article, :only => [:index]) }
      }.should_not raise_error
    end
    
    it "instantiates a new Sinatra::Hat::Maker" do
      mock.proxy(Sinatra::Hat::Maker).new(Article, { })
      mock_app { mount(Article) }
    end
    
    it "instance_eval's the block in the new maker" do
      mock.proxy(maker = new_maker).instance_eval
      mock.proxy(Sinatra::Hat::Maker).new(Article, { }) { maker }
      mock_app { mount(Article, &proc { }) }
    end
    
    it "generates routes" do
      mock.proxy.instance_of(Sinatra::Hat::Maker).generate_routes(anything)
      mock_app { mount(Article) }
    end
  end
end
