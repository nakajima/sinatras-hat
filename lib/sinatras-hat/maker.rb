module Sinatra
  module Hat
    # This is where it all comes together
    class Maker
      include Sinatra::Hat::Extendor
      
      attr_reader :klass, :app
      
      def self.actions
        @actions ||= { }
      end
      
      def self.action(name, path, options={}, &block)
        verb = options[:verb] || :get
        Router.cache << [verb, name, path]
        actions[name] = block
      end

      include Sinatra::Hat::Actions
      
      #  ======================================================
      
      def initialize(klass, overrides={})
        @klass = klass
        options.merge!(overrides)
        with(options)
      end
      
      def setup(app)
        @app = app
        generate_routes(app)
      end
      
      def handle(action, request)
        # puts ">> #{action.to_s.upcase}: #{request.params.inspect}"
        instance_exec(request, &self.class.actions[action])
      end
      
      def after(action)
        yield HashMutator.new(responder.defaults[action])
      end
      
      def prefix
        @prefix ||= options[:prefix] || model.plural
      end
      
      def parents
        @parents ||= parent ? Array(parent) + parent.parents : []
      end
      
      def resource_path(suffix, record=nil)
        resource.path(suffix, record)
      end
      
      def options
        @options ||= {
          :parent => nil,
          :finder => proc { |model, params| model.all },
          :record => proc { |model, params| model.first(:id => params[:id]) },
          :formats => { }
        }
      end
      
      def inspect
        "maker: #{klass}"
      end
      
      def generate_routes(app)
        Router.new(self).generate(app)
      end
      
      def responder
        @responder ||= Responder.new(self)
      end
      
      def model
        @model ||= Model.new(self)
      end
      
      private
      
      def resource
        @resource ||= Resource.new(self)
      end
    end
  end
end