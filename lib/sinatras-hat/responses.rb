module Sinatra
  module Hat
    # TODO: Move these to Action class?
    module Responses
      class UnsupportedFormat < StandardError
        attr_reader :format
        
        def initialize(format)
          @format = format
        end
      end
      
      def templated(event, name, opts={}, &block)
        event.protect!(:realm => credentials[:realm], &authenticator) if protecting?(name)
        
        root = File.join(Sinatra.application.options.views, prefix)
        result = actions[name].handle(event)
        event.instance_variable_set ivar_name(result), result
        return opts[:verb] == :get ?
          event.render(renderer, name, :views_directory => root) :
          event.redirect(redirection_path(result))
      end
    
      def serialized(event, name, opts={}, &block)
        format = event.params[:format].to_sym
        
        event.protect!(:realm => credentials[:realm], &authenticator) if protecting?(name)
        
        if accepts[format] or opts[:verb].eql?(:get)
          event.content_type(format) rescue nil
          object = actions[name].handle(event)
          result = serializer_for(format).call(object)
          return result unless result.nil?
        end
      
        raise UnsupportedFormat.new(format)
      end
      
      private
      
      def serializer_for(format)
        formats[format.to_sym] ||= proc do |object|
          object.try("to_#{format}")
        end
      end
      
      def protecting?(name)
        protect.include?(:all) or protect.include?(name)
      end
    
      def redirection_path(result)
        result.is_a?(Symbol) ?
          "/#{prefix}" :
          "/#{prefix}/#{result.send(to_param)}"
      end
    
      def ivar_name(result)
        "@" + (result.respond_to?(:each) ? prefix : model.name.downcase)
      end
    end
  end
end