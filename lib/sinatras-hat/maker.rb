module Sinatra
  module Hat
    # This is where it all comes together
    class Maker
      include Sinatra::Hat::Extendor
      
      attr_reader :klass, :app
      
      def self.actions
        @actions ||= { }
      end
      
      # enables the douche-y DSL you see in actions.rb
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
      end
      
      def handle(action, request)
        logger.info ">> #{request.env['REQUEST_METHOD']} #{request.env['PATH_INFO']}"
        logger.info "   action: #{action.to_s.upcase}"
        logger.info "   params: #{request.params.inspect}"
        request.error(404) unless only.include?(action)
        instance_exec(request, &self.class.actions[action])
      end
      
      def after(action)
        yield HashMutator.new(responder.defaults[action])
      end
      
      def finder(&block)
        if block_given?
          options[:finder] = block
        else
          options[:finder]
        end
      end
      
      def record(&block)
        if block_given?
          options[:record] = block
        else
          options[:record]
        end
      end
      
      def only(*actions)
        if actions.empty?
          options[:only]
        else
          options[:only] = actions
        end
      end
      
      def prefix
        @prefix ||= options[:prefix] || model.plural
      end
      
      def parents
        @parents ||= parent ? Array(parent) + parent.parents : []
      end
      
      def resource_path(*args)
        resource.path(*args)
      end
      
      def options
        @options ||= {
          :only => [:index, :show, :new, :create, :edit, :update, :destroy],
          :parent => nil,
          :finder => proc { |model, params| model.all },
          :record => proc { |model, params| model.find_by_id(params[:id]) },
          :formats => { }
        }
      end
      
      def inspect
        "maker: #{klass}"
      end
      
      def generate_routes!
        Router.new(self).generate(@app)
      end
      
      def responder
        @responder ||= Responder.new(self)
      end
      
      def model
        @model ||= Model.new(self)
      end
      
      # TODO Hook this into Rack::CommonLogger
      def logger
        @logger ||= Logger.new(self)
      end
      
      private
      
      def resource
        @resource ||= Resource.new(self)
      end
    end
  end
end