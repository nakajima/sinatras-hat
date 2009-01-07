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
    end
  end
end