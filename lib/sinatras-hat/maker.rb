module Sinatra
  module Hat
    class Maker
      attr_reader :klass
      
      def initialize(klass, overrides={})
        @klass = klass
        options.merge!(overrides)
        with(options)
      end
      
      def handle_index(request)
        records = model.all(request.params)
        request.instance_variable_set("@#{prefix}", records)
      end
      
      def model
        @model ||= Model.new(self)
      end
      
      def prefix
        options[:prefix] || klass.name.snake_case.plural
      end
      
      def parents
        parent ? Array(parent) + parent.parents : []
      end
      
      def resource_path(suffix)
        (@resource ||= Resource.new(self)).path(suffix)
      end
      
      def options
        @options ||= {
          :finder => proc { |model, params| model.all },
          :record => proc { |model, params| model.first(:id => params[:id]) },
          :parent => nil
        }
      end
    end
  end
end