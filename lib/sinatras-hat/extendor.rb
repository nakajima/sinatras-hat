module Sinatra
  module Hat
    module Extendor
      def mount(klass, options={}, &block)
        Maker.new(klass, options).tap do |maker|
          maker.parent = self if kind_of?(Sinatra::Hat::Maker)
          maker.setup(@app || self)
          maker.instance_eval(&block) if block_given?
        end
      end
    end
  end
end

Sinatra::Base.extend(Sinatra::Hat::Extendor)
