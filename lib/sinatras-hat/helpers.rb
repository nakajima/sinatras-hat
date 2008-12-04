module Sinatra
  module Hat
    module Helpers
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
    
      def parse_for_attributes(params, name=model.name.downcase)
        if handler = accepts[params[:format].try(:to_sym)]
          handler.call params[name]
        else
          params.nest!
          params[name] ||= { }
          params[name][parent.model_id] = params[parent.model_id] if parent
          params[name]
        end
      end
    end
  end
end