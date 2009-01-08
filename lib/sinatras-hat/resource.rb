module Sinatra
  module Hat
    class Resource
      def initialize(maker)
        @maker = maker
      end
      
      def path(suffix)
        path = resources.inject("") do |memo, maker|
          memo += @maker.eql?(maker) ?
            "/#{maker.prefix}" :
            "/#{maker.prefix}/:#{maker.model.singular}_id"
        end
        
        clean(path + suffix)
      end
      
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
