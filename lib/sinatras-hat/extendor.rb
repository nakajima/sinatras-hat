module Sinatra
  module Hat
    # This module gives both Sinatra::Base and Sinatra::Hat::Maker
    # the #mount method, which is used to mount resources. When
    # mount is called in an instance of Maker, it sets the new
    # instance's parent.
    module Extendor
      def mount(klass, options={}, &block)
        unless kind_of?(Sinatra::Hat::Maker)
          use Rack::MethodOverride 
        end
        
        Maker.new(klass, options).tap do |maker|
          maker.parent = self if kind_of?(Sinatra::Hat::Maker)
          maker.setup(@app || self)
          maker.instance_eval(&block) if block_given?
          maker.generate_routes!
        end
      end
    end
  end
end

Sinatra::Base.extend(Sinatra::Hat::Extendor)
