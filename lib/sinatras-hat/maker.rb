module Sinatra
  module Hat
    # This is where it all comes together
    class Maker
      include Sinatra::Hat::Extendor
      include Sinatra::Authorization::Helpers
      
      attr_reader :klass, :app
      
      def self.actions
        @actions ||= { }
      end
      
      def self.action(name, path, options={}, &block)
        verb = options[:verb] || :get
        Router.cache << [verb, name, path]
        actions[name] = { :path => path, :verb => verb, :fn => block }
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
        request.error(404) unless only.include?(action)
        protect!(request) if protect.include?(action)
        
        log_with_benchmark(request, action) do
          instance_exec(request, &self.class.actions[action][:fn])
        end
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
      
      def authenticator(&block)
        if block_given?
          options[:authenticator] = block
        else
          options[:authenticator]
        end
      end
      
      def only(*actions)
        if actions.empty?
          options[:only] ||= Set.new(options[:only])
        else
          Set.new(options[:only] = actions)
        end
      end
      
      def protect(*actions)
        credentials.merge!(actions.extract_options!)
        
        if actions.empty?
          options[:protect] ||= Set.new([])
        else
          actions == [:all] ? 
            Set.new(options[:protect] = only) :
            Set.new(options[:protect] = actions)
        end
      end
      
      def prefix
        options[:prefix] ||= model.plural
      end
      
      def parents
        @parents ||= parent ? Array(parent) + parent.parents : []
      end
      
      def resource_path(*args)
        resource.path(*args)
      end
      
      def options
        @options ||= {
          :only => Set.new(Maker.actions.keys),
          :parent => nil,
          :finder => proc { |model, params| model.all },
          :record => proc { |model, params| model.find_by_id(params[:id]) },
          :protect => [ ],
          :formats => { },
          :credentials => { :username => 'username', :password => 'password', :realm => "The App" },
          :authenticator => proc { |username, password| [username, password] == [:username, :password].map(&credentials.method(:[])) }
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
      
      def resource
        @resource ||= Resource.new(self)
      end
      
      private
      
      def log_with_benchmark(request, action)
        msg = [ ]
        msg << "#{request.env['REQUEST_METHOD']} #{request.env['PATH_INFO']}"
        msg << "Params: #{request.params.inspect}"
        msg << "Action: #{action.to_s.upcase}"
        
        logger.info "[sinatras-hat] " + msg.join(' | ')
        
        result = nil
        
        t = Benchmark.realtime { result = yield }
        
        logger.info "               Request finished in #{t} sec."
        
        result
      end
    end
  end
end