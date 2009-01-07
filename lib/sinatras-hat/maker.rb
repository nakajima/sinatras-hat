module Sinatra
  module Hat
    class Maker
      attr_reader :klass
      
      def initialize(klass, overrides={})
        @klass = klass
        options.merge!(overrides)
        with(options)
      end
      
      def prefix
        options[:prefix] || klass.name.downcase.plural
      end
      
      def parents
        parent ? Array(parent) + parent.parents : []
      end
      
      def resource_path(suffix)
        resource.path(suffix)
      end
      
      def options
        @options ||= {
          :finder => proc { |model, params| model.all },
          :record => proc { |model, params| model.first(:id => params[:id]) },
          :parent => nil
        }
      end
      
      private
      
      def resource
        @resource ||= Resource.new(self)
      end
    end
  end
end