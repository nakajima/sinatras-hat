module Sinatra
  module Hat
    class Responder
      attr_reader :maker
      
      def initialize(maker)
        @maker = maker
      end
      
      def serialize(data, options={})
        name = options[:format].to_sym
        formatter = maker.formats[name] || to_format(name)
        formatter[data]
      end
      
      private
      
      def to_format(name)
        @default_formatter ||= Proc.new { |data| data.send("to_#{name}") }
      end
    end
  end
end