module Sinatra
  module Hat
    class Resource
      def initialize(maker)
        @maker = maker
      end
      
      def path(suffix)
        makers = @maker.parents + [@maker]
        path = makers.inject("") do |memo, maker|
          memo += @maker.eql?(maker) ?
            "/#{maker.prefix}" :
            "/#{maker.prefix}/:#{maker.klass.name}_id"
        end
        (path + suffix).tap do |s|
          s.downcase!
          s.gsub!(%r(/$), '')
        end
      end
    end
  end
end
