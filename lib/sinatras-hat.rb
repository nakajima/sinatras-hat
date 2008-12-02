$LOAD_PATH << File.join(File.dirname(__FILE__), 'core_ext')
$LOAD_PATH << File.join(File.dirname(__FILE__), 'sinatras-hat')

require 'erb'
require 'extlib'
require 'dm-core'
require 'dm-serializer'
require 'array'
require 'proc'
require 'object'
require 'actions'
require 'child_actions'
require 'responses'
require 'helpers'

load 'auth.rb'

Rack::File::MIME_TYPES['json'] = 'text/x-json'
Rack::File::MIME_TYPES['yaml'] = 'text/x-yaml'

module Sinatra
  module Hat
    class Maker
      attr_reader :model, :context, :options

      include Actions, ChildActions, Responses, Helpers
      
      def initialize(model)
        @model = model
        with(options)
      end
    
      def define(context, opts={}, &block)
        @context = context
        @options.merge!(opts)
        instance_eval &block if block_given?
        generate_child_actions!
        generate_actions!
      end

      def prefix
        options[:prefix]
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
        
        # we need the index action to be last or else it picks
        # up the other actions due to the paths. hacky? yes.
        if action = result.delete(:index)
          result << action 
        end
        
        result
      end
      
      def children(*args)
        result = get_or_set_option(:children, args) do
          self.children = args
          self.children.uniq!
        end
        
        [result].flatten
      end
      
      def finder(&block)
        if block_given?
          @finder = proc(&block)
        else
          @finder ||= proc { |params| all }
        end
      end
      
      def record(&block)
        if block_given?
          @record = proc(&block)
        else
          @record ||= proc { |params| first(:id => params[:id]) }
        end
      end
      
      def map(name, path, opts={}, &block)
        opts[:verb] ||= :get
        klass = self
      
        handler = proc do
          protect!(:realm => klass.credentials[:realm]) do |user, pass|
            user == klass.credentials[:username] and pass == klass.credentials[:password]
          end if klass.protecting?(name)
          format = request.env['PATH_INFO'].split('.')[1]
          format ? 
            klass.serialized_response(self, format.to_sym, opts, &block) :
            klass.templating_response(self, name, opts, &block)
        end
      
        context.send(opts[:verb], path, &handler)
        context.send(opts[:verb], "#{path}.:format", &handler)
      end
      
      def call(method, params, opts={})
        fn = send(method)
        klass = opts[:on] || model
        klass.instance_exec(params, &fn)
      end
      
      def options
        @options ||= {
          :only => [:show, :create, :update, :destroy, :index],
          :prefix => Extlib::Inflection.tableize(model.name),
          :protect => [],
          :parents => [],
          :formats => { },
          :renderer => :erb,
          :children => [],
          :to_param => :id,
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

def mount(model, opts={}, &block)
  Sinatra::Hat::Maker.new(model).define(self, opts, &block)
end