require 'extlib'
require 'dm-core'
require 'dm-serializer'
require File.join(File.dirname(__FILE__), 'core_ext', 'object')

module Sinatra
  class Hat
    attr_reader :model, :context, :options
    
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

    def index!
      map :get, "/#{prefix}" do |params|
        finder.call(params)
      end
    end
    
    def show!
      map :get, "/#{prefix}/:id" do |params|
        result = record.call(params)
        result
      end
    end
    
    def create!
      map :post, "/#{prefix}" do |params|
        result = model.new
        result.attributes = parse_for_attributes!(params)
        result.save
        result
      end
    end
    
    def update!
      map :put, "/#{prefix}/:id" do |params|
        result = record.call(params)
        result.attributes = parse_for_attributes!(params)
        result.save
        result
      end
    end
    
    def destroy!
      map :delete, "/#{prefix}/:id", :no_format => true do |params|
        result = record.call(params)
        result.destroy
        :ok
      end
    end

    def accepts
      @accepts ||= {
        :json => proc { |string| JSON.parse(string) },
        :xml  => proc { |string| Hash.from_xml(string)['hash'] }
      }
    end
    
    def formats
      @formats ||= { }
    end
    
    def options
      @options ||= {
        :finder => proc { |params| model.all },
        :record => proc { |params| model.first(:id => params[:id]) },
        :only => [:index, :show, :create, :update, :destroy]
      }
    end
    
    def map(verb, path, opts={}, &block)
      opts[:no_format] ? 
        handle_without_format(verb, path, &block) : 
        handle_with_format(verb, path, &block)
    end
    
    private
    
    def handle_without_format(verb, path, &block)
      context.send(verb, path) do
        block.call(params)
      end
    end
    
    def handle_with_format(verb, path, &block)
      klass = self
      
      context.send(verb, path) do
        throw :halt, [400, "\nYou must specify format in your path. Example: #{path}.json\n"]
      end
      
      context.send(verb, "#{path}.:format") do
        format = params[:format].downcase.to_sym
        
        if klass.accepts[format] or verb.eql?(:get)
          object = block.call(params)
          handle = klass.formats[format]
          result = handle ? handle.call(object) : object.try("to_#{format}")
          next result unless result.nil?
        end
        
        throw :halt, [
          406, [
            "The `#{format}` format is not supported.\n",
            "Valid Formats: #{klass.accepts.keys.join(', ')}\n",
          ].join("\n")
        ]
      end
    end
    
    def parse_for_attributes!(params)
      handler = accepts[params[:format].to_sym]
      handler.call params[prefix.singularize]
    end
    
    def prefix
      @prefix ||= Extlib::Inflection.tableize(model.name)
    end
  end
end

def mount(model, opts={}, &block)
  Sinatra::Hat.new(model).define(self, opts, &block)
end
