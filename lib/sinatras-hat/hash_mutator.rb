module Sinatra
  module Hat
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