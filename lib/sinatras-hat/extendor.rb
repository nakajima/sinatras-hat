module Sinatra
  module Hat
    module Extendor
      def mount(klass, options={}, &block)
        maker = Maker.new(klass, options)
        maker.instance_eval(&block) if block_given?
        maker
      end
    end
  end
end

Sinatra::Base.extend(Sinatra::Hat::Extendor)