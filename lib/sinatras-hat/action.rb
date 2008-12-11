module Sinatra
  module Hat
    class Action
      attr_reader :maker, :handler
      
      def initialize(maker, handler)
        @maker, @handler = maker, handler
      end
      
      def handle(event)
        handler[event.params]
      end
    end
  end
end