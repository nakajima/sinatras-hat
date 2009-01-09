module Sinatra
  module Hat
    # The responder assigns data to instance variables, then either
    # gets the appropriate response proc and instance_exec's it in the
    # context of a new Response object, or serializes the data.
    class Responder
      delegate :model, :to => :maker
      
      DEFAULTS = {
        :show => {
          :success => proc { |data| render(:show) },
          :failure => proc { |data| redirect('/') }
        },
        
        :index => {
          :success => proc { |data| render(:index) },
          :failure => proc { |data| redirect('/') }
        },
        
        :create => {
          :success => proc { |data| redirect(data) },
          :failure => proc { |data| render(:new) }
        },
        
        :new => {
          :success => proc { |data| render(:new) },
          :failure => proc { |data| redirect('/') }
        },
        
        :edit => {
          :success => proc { |data| render(:edit) }
        },
        
        :destroy => {
          :success => proc { |data| redirect(resource_path('/')) }
        }
      }
      
      attr_reader :maker
      
      def initialize(maker)
        @maker = maker
      end
      
      def defaults
        @defaults ||= DEFAULTS.dup
      end
      
      def success(name, request, data)
        handle(:success, name, request, data)
      end
      
      def failure(name, request, data)
        handle(:failure, name, request, data)
      end
      
      def serialize(format, data)
        name = format.to_sym
        formatter = maker.formats[name] || to_format(name)
        formatter[data]
      end
      
      private
      
      def handle(result, name, request, data)
        if format = request.params[:format]
          serialize(format, data)
        else
          request.instance_variable_set(ivar_name(data), data)
          response = Response.new(maker, request)
          response.instance_exec(data, &defaults[name][result])
        end
      end
      
      def ivar_name(data)
        "@" + (data.respond_to?(:each) ? model.plural : model.singular)
      end
      
      def to_format(name)
        Proc.new { |data| data.send("to_#{name}") }
      end
    end
  end
end