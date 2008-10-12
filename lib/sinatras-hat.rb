$LOAD_PATH << File.join(File.dirname(__FILE__), 'core_ext')
$LOAD_PATH << File.join(File.dirname(__FILE__), 'sinatras-hat')

require 'erb'
require 'extlib'
require 'dm-core'
require 'dm-serializer'
require 'array'
require 'object'
require 'actions'
require 'responses'
require 'helpers'

load 'auth.rb'

Rack::File::MIME_TYPES['json'] = 'text/x-json'
Rack::File::MIME_TYPES['yaml'] = 'text/x-yaml'

module Sinatra
  module Hat
    class Maker
      attr_reader :model, :context, :options, :credentials

      include Actions, Responses, Helpers
      
      def initialize(model)
        @model = model
        with(options)
      end
    
      def define(context, opts={})
        @context = context
        @options.merge!(opts)
        yield self, model if block_given?
        [only].flatten.each { |action| send("#{action}!") }
      end

      def protect(*args)
        opts = args.extract_options!
        credentials.update(opts)
        if args.length > 0
          @protect ||= []
          @protect += args
          @protect.uniq!
        else
          @protect ||= []
        end
      end
    
      def map(name, path, opts={}, &block)
        opts[:no_format] ? 
          handle_without_format(name, path, opts, &block) : 
          handle_with_format(name, path, opts, &block)
      end
      
      def options
        @options ||= {
          :finder => proc { |params| model.all },
          :record => proc { |params| model.first(:id => params[:id]) },
          :only => [:show, :create, :update, :destroy, :index],
          :renderer => :erb,
          :realm => 'The App',
          :prefix => Extlib::Inflection.tableize(model.name),
          :credentials => { :username => 'admin', :password => 'password' },
          :formats => { },
          :accepts => {
            :yaml => proc { |string| YAML.load(string) },
            :json => proc { |string| JSON.parse(string) },
            :xml  => proc { |string| Hash.from_xml(string)['hash'] }
          }
        }
      end
    end
  end
end

def mount(model, opts={}, &block)
  Sinatra::Hat::Maker.new(model).define(self, opts, &block)
end