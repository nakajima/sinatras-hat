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
        
        parents = path_records_for(record) if record
        
        path = resources.inject("") do |memo, maker|
          memo += fragment(maker, record)
        end
        
        path = clean(path + suffix)
        path.gsub!(/:(\w+)/) { parents.pop.send(@maker.to_param) } if record
        path
      end
      
      private
      
      def path_records_for(record)
        [record].tap do |parents|
          resources.reverse.each do |resource|
            parents << resource.model.find_owner(parents.last.attributes)
            parents.compact!
            parents.uniq!
          end
        end
      end
      
      def fragment(maker, record)
        @maker.eql?(maker) ?
          "/#{maker.prefix}" :
          "/#{maker.prefix}/" + key(maker)
      end
      
      def key(maker)
        maker.model.foreign_key.inspect
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
