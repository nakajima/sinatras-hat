module Sinatra
  module Hat
    module Responses
      def templating_response(event, name, opts={}, &block)
        event.params.nest!
        dir = opts[:view_as] || prefix
        root = File.join(Sinatra.application.options.views, dir)
        result = block.call(event.params)
        event.instance_variable_set ivar_name(result), result
        return opts[:verb] == :get ?
          event.render(renderer, name, :views_directory => root) :
          event.redirect(redirection_path(result))
      end
    
      def serialized_response(event, format, opts={}, &block)
        if accepts[format] or opts[:verb].eql?(:get)
          event.content_type format rescue nil
          object = block.call(event.params)
          handle = formats[format.to_sym]
          result = handle ? handle.call(object) : object.try("to_#{format}")
          return result unless result.nil?
        end
      
        throw :halt, [
          406, [
            "The `#{format}` format is not supported.\n",
            "Valid Formats: #{accepts.keys.join(', ')}\n",
          ].join("\n")
        ]
      end
    end
  end
end