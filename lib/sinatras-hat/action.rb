module Sinatra
  module Hat
    class Action
      attr_reader :maker, :name, :handler, :options
      
      def initialize(maker, name, handler, options={})
        @maker, @name, @handler, @options = maker, name, handler, options
      end
      
      def handle(event)
        handler[event.params]
      end
    end
  end
end