module Sinatra
  module Hat
    module Responses
      def templating_response(context, name, verb, &block)
        root = File.join(Sinatra.application.options.views, prefix)
        params = railsify_params(context.params)
        result = block.call(params)
        context.instance_variable_set ivar_name(result), result
        return verb == :get ?
          context.render(renderer, name, :views_directory => root) :
          context.redirect(redirection_path(result))
      end
    
      def serialized_response(context, format, verb, &block)
        if accepts[format] or verb.eql?(:get)
          context.content_type format rescue nil
          object = block.call(context.params)
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