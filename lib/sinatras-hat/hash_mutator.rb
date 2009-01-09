module Sinatra
  module Hat
    # Used for specifying custom responses using a corny DSL.
    class HashMutator
      def initialize(hash)
        @hash = hash
      end
      
      def success(&block)
        @hash[:success] = block
      end
      
      def failure(&block)
        @hash[:failure] = block
      end
    end
  end
end