module Sinatra
  module Hat
    module Extendor
      def mount(klass, options={}, &block)
        options[:parent] = self if kind_of?(Sinatra::Hat::Maker)
        maker = Maker.new(klass, options)
        maker.setup(@app || self)
        maker.instance_eval(&block) if block_given?
        maker
      end
    end
  end
end

Sinatra::Base.extend(Sinatra::Hat::Extendor)
