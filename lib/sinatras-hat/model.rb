module Sinatra
  module Hat
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
      
      def plural
        klass.name.snake_case.plural
      end
      
      def singular
        klass.name.snake_case.singular
      end
    end
  end
end