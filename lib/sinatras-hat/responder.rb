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
            :success => proc { |data| render(:show) },
            :failure => proc { |data| redirect('/') }
          },
          
          :index => {
            :success => proc { |data| render(:index) },
            :failure => proc { |data| throw(:halt) }
          },
          
          :create => {
            :success => proc { |data| redirect(data) },
            :failure => proc { |data| redirect('/') }
          }
        }
      end
      
      def handle(name, request, data, &block)
        if request.params[:format]
          serialize(request, data)
        else
          request.instance_variable_set(ivar_name(data), data)
          Response.new(maker, request).instance_exec(data, &defaults[name][:success])
        end
      end
      
      def serialize(request, data)
        name = request.params[:format].to_sym
        maker.formats[name] ||= to_format(name)
        maker.formats[name][data]
      end
      
      private
      
      def ivar_name(data)
        "@" + (data.respond_to?(:each) ? model.plural : model.singular)
      end
      
      def to_format(name)
        @default_formatter ||= Proc.new { |data| data.send("to_#{name}") }
      end
    end
  end
end