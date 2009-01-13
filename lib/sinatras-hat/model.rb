module Sinatra
  module Hat
    # A wrapper around the model class that we're mounting
    class Model
      attr_reader :maker
      
      delegate :options, :klass, :prefix, :to => :maker
      
      def initialize(maker)
        @maker = maker
      end
      
      def all(params)
        options[:finder].call(klass, params)
      end
      
      def find(params)
        options[:record].call(klass, params)
      end
      
      def update(params)
        if record = find(params)
          params.nest!
          record.attributes = (params[singular] || { })
          record
        end
      end
      
      def new(params={})
        params.nest!
        proxy(params).new(params[singular] || { })
      end
      
      def plural
        klass.name.snake_case.plural
      end
      
      def singular
        klass.name.snake_case.singular
      end
      
      private
      
      def proxy(params)
        return klass unless parent
        owner = parent.find(params)
        if owner and owner.respond_to?(plural)
          owner.send(plural)
        else
          klass
        end
      end
      
      def parent
        return nil unless maker.parent
        maker.parent.model
      end
    end
  end
end