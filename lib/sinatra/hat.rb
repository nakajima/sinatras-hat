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
      yield self if block_given?
      @context = context
      self.options.merge!(opts)
      [only].flatten.each { |action| send("#{action}!") }
    end

    def index!
      map :get, "/#{prefix}" do |params|
        model.send(*finder)
      end
    end
    
    def show!
      map :get, "/#{prefix}/:id" do |params|
        record = model.find(params[:id])
        record
      end
    end
    
    def create!
      map :post, "/#{prefix}" do |params|
        record = model.new
        record.attributes = parse_for_attributes!(params)
        record.save
        record
      end
    end
    
    def update!
      map :put, "/#{prefix}/:id" do |params|
        record = model.find(params[:id])
        record.attributes = parse_for_attributes!(params)
        record.save
        record
      end
    end
    
    def destroy!
      map :delete, "/#{prefix}/:id", :no_format => true do |params|
        record = model.find(params[:id])
        record.destroy
        :ok
      end
    end

    def formats
      @formats ||= {
        :json => proc { |string| JSON.parse(string) },
        :xml  => proc { |string| Hash.from_xml(string)['hash'] }
      }
    end
    
    def options
      @options ||= {
        :finder => [:all],
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
      valid_formats = formats
      
      context.send(verb, path) do
        throw :halt, [400, "\nYou must specify format in your path. Example: #{path}.json\n"]
      end
      
      context.send(verb, "#{path}.:format") do
        format = params[:format].downcase.to_sym
        
        next block.call(params).send("to_#{format}") if valid_formats[format]
        
        throw :halt, [
          406, [
            "The `#{format}` format is not supported.\n",
            "Valid Formats: #{valid_formats.keys.join(', ')}\n",
          ].join("\n")
        ]
      end
    end
    
    def parse_for_attributes!(params)
      handler = formats[params[:format].to_sym]
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
