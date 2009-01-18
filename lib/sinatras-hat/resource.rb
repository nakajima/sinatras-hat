module Sinatra
  module Hat
    # Handles the logic of generating a path for a given resource,
    # taking any and all parents into consideration.
    class Resource
      def initialize(maker)
        @maker = maker
      end
      
      def path(suffix, record=nil)
        suffix = suffix.dup
        
        path = resources.inject("") do |memo, maker|
          memo += fragment(maker, record)
        end
        
        suffix.gsub!('/:id', "/#{record.id}") if record
        
        clean(path + suffix)
      end
      
      private
      
      def fragment(maker, record)
        @maker.eql?(maker) ?
          "/#{maker.prefix}" :
          "/#{maker.prefix}/" + interpolate(maker, record)
      end
      
      def interpolate(maker, record)
        foreign_key = maker.model.foreign_key
        result = record ? record.send(foreign_key) : foreign_key
        result.inspect
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
