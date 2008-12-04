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
        value = params[name.to_s.singularize]
        if handler = accepts[params[:format].try(:to_sym)]
          handler.call value
        else
          value
        end
      end
    end
  end
end