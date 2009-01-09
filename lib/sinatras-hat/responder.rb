module Sinatra
  module Hat
    class Responder
      delegate :model, :to => :maker
      
      attr_reader :maker
      
      def initialize(maker)
        @maker = maker
      end
      
      def defaults
        @defaults ||= {
          :show => {
            :success => proc { |data| render(:show) }
          },
          
          :index => {
            :success => proc { |data| render(:index) }
          },
          
          :create => {
            :success => proc { |data| redirect(data) }
          },
          
          :new => {
            :success => proc { |data| render(:new) }
          }
        }
      end
      
      def handle(name, request, data, &block)
        if format = request.params[:format]
          serialize(format, data)
        else
          request.instance_variable_set(ivar_name(data), data)
          response = Response.new(maker, request)
          response.instance_exec(data, &defaults[name][:success])
        end
      end
      
      def serialize(format, data)
        name = format.to_sym
        formatter = maker.formats[name] || to_format(name)
        formatter[data]
      end
      
      private
      
      def ivar_name(data)
        "@" + (data.respond_to?(:each) ? model.plural : model.singular)
      end
      
      def to_format(name)
        Proc.new { |data| data.send("to_#{name}") }
      end
    end
  end
end