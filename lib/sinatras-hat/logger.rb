module Sinatra
  module Hat
    # TODO This needs to be using Rack::CommonLogger
    class Logger
      def initialize(maker)
        @maker = maker
      end
      
      def info(msg)
        say msg
      end
      
      def debug(msg)
        say msg
      end
      
      def warn(msg)
        say msg
      end
      
      def error(msg)
        say msg
      end
      
      def fatal(msg)
        say msg
      end
      
      private
      
      def say(msg)
        puts msg if @maker.app and @maker.app.logging
      end
    end
  end
end