module Sinatra
  module Hat
    module Responses
      def templating_response(context, name, opts={}, &block)
        dir = opts[:view_as] || prefix
        root = File.join(Sinatra.application.options.views, dir)
        params = railsify_params(context.params)
        result = block.call(params)
        context.instance_variable_set ivar_name(result), result
        return opts[:verb] == :get ?
          context.render(renderer, name, :views_directory => root) :
          context.redirect(redirection_path(result))
      end
    
      def serialized_response(context, format, opts={}, &block)
        if accepts[format] or opts[:verb].eql?(:get)
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