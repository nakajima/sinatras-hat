module Sinatra
  module Hat
    class Maker
      attr_accessor :parent
      attr_reader :model, :context, :options
      
      include Actions, Responses
      
      def initialize(model)
        @model = model
        with(options)
      end
    
      def define(context, opts={}, &block)
        @context = context
        @options.merge!(opts)
        instance_eval(&block) if block_given?
        generate_actions!
      end
      
      def mount(klass, opts={}, &block)
        child = Maker.new(klass)
        child.parent = self
        child.define(context, opts, &block)
        child
      end
      
      def resource_path(suffix)
        resources = parents + [self]
        path = resources.inject("") do |memo, maker|
          memo += eql?(maker) ?
            "/#{maker.prefix}" :
            "/#{maker.prefix}/:#{maker.model.name}_id"
        end
        (path + suffix).tap do |s|
          s.downcase!
          s.gsub!(%r(/$), '')
        end
      end
      
      def parents
        @parents ||= parent ? Array(parent) + parent.parents : []
      end

      def protect(*args)
        opts = args.extract_options!
        credentials.update(opts)
        actions = get_or_set_option(:protect, args) do
          self.protect += args
          self.protect.uniq!
        end
        
        [actions].flatten
      end

      def only(*args)
        result = get_or_set_option(:only, args) do
          self.only = args
          self.only.uniq!
        end
        
        result = Array(result)
        
        result.move_to_back(:index)
        result.move_to_front(:new, :edit)
        
        result
      end
      
      def children(*args)
        result = get_or_set_option(:children, args) do
          self.children = args
          self.children.uniq!
        end
        
        [result].flatten
      end
      
      def authenticator(&block)
        if block_given?
          @authenticator = block
        else
          @authenticator ||= proc { |username, password|
            credentials[:username] == username and credentials[:password] == password
          }
        end
      end
      
      def finder(&block)
        if block_given?
          @finder = block
        else
          @finder ||= proc { |params| all }
        end
      end
      
      def record(&block)
        if block_given?
          @record = block
        else
          @record ||= proc { |params| first(:id => params[:id]) }
        end
      end
      
      def map(name, path, opts={}, &block)
        opts[:verb] ||= :get
        klass = self
        actions[name] = Action.new(self, name, block, opts)
      
        context.send(opts[:verb], path) do
          begin
            klass.templated(self, name, opts, &block)
          rescue Errno::ENOENT => e
            klass.rescue_template_error(e)
          end
        end
        
        context.send(opts[:verb], "#{path}.:format") do
          begin
            klass.serialized(self, name, opts, &block)
          rescue UnsupportedFormat => e
            klass.rescue_format_error(e)
          end
        end
      end
      
      def rescue_format_error(e)
        throw :halt, [
          406, [
            "The `#{e.format}` format is not supported.\n",
            "Valid Formats: #{accepts.keys.join(', ')}\n",
          ].join("\n")
        ]
      end

      # TODO Create a real template for this error.
      def rescue_template_error(e)
        msg = "<pre>There was a problem with your view template:\n\n  "
        msg << e.message
        msg << "\n</pre>"
      end
      
      def call(method, params)
        proxy(params).instance_exec(params, &send(method))
      end
      
      def proxy(params={})
        return model if parent.nil?
        fake_params = params.dup
        fake_params.merge!("id" => params[parent.model_id])
        fake_params.make_indifferent!
        parent.call(:record, fake_params).try(prefix) || model
      end
      
      def model_id
        "#{model.name.downcase}_id".to_sym
      end
      
      def options
        @options ||= {
          :only => [:new, :edit, :show, :create, :update, :destroy, :index],
          :prefix => Extlib::Inflection.tableize(model.name),
          :actions => { },
          :protect => [ ],
          :formats => { },
          :renderer => :erb,
          :children => [],
          :to_param => :id,
          :nest_params => true,
          :credentials => {
            :username => 'admin',
            :password => 'password',
            :realm => 'TheApp.com'
          },
          :accepts => {
            :yaml => proc { |string| YAML.load(string) },
            :json => proc { |string| JSON.parse(string) },
            :xml  => proc { |string| Hash.from_xml(string)['hash'] }
          }
        }
      end
      
      private
      
      def get_or_set_option(name, args, opts={})
        args.length > 0 ? yield : options[name]
      end
    end
  end
end