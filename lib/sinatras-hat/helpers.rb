module Sinatra
  module Hat
    module Helpers
      def protecting?(name)
        protect.include?(:all) or protect.include?(name)
      end
    
      def railsify_params(params)
        new_params = { }
        params = params.dup
        params.each_pair do |full_key, value| 
          this_param = new_params 
          split_keys = full_key.split(/\]\[|\]|\[/) 
          split_keys.each_index do |index| 
            break if split_keys.length == index + 1 
            this_param[split_keys[index]] ||= {} 
            this_param = this_param[split_keys[index]] 
          end 
          this_param[split_keys.last] = value 
        end 
        params.clear
        params.merge! new_params 
        params
      end
    
      def redirection_path(result)
        result.is_a?(Symbol) ?
          "/#{prefix}" :
          "/#{prefix}/#{result.send(to_param)}"
      end
    
      def plural?(result)
        result.respond_to?(:length)
      end
    
      def ivar_name(result)
        "@" + (plural?(result) ? prefix : model.name.downcase)
      end
    
      def parse_for_attributes!(params, name=model.name.downcase)
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