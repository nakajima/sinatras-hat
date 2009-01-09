module Sinatra
  module Hat
    # Handles the logic of generating a path for a given resource,
    # taking any and all parents into consideration.
    class Resource
      def initialize(maker)
        @maker = maker
      end
      
      def path(suffix, record=nil)
        path = resources.inject("") do |memo, maker|
          memo += @maker.eql?(maker) ?
            "/#{maker.prefix}" :
            "/#{maker.prefix}/:#{maker.model.singular}_id"
        end
        
        suffix.gsub!(/:id/, record.id.to_s) if record
        
        clean(path + suffix)
      end
      
      private
      
      def clean(s)
        s.downcase!
        s.gsub!(%r(/$), '')
        s
      end
      
      def resources
        @maker.parents + [@maker]
      end
    end
  end
end
