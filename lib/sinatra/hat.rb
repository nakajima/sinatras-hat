require 'extlib'
require 'dm-core'
require 'dm-serializer'
require File.join(File.dirname(__FILE__), 'core_ext', 'object')

module Sinatra
  class Hat
    attr_reader :model, :context, :options
    
    VALID_FORMATS = ['xml', 'json'] unless defined?(VALID_FORMATS)
    
    def initialize(model)
      @model = model
      with(options)
    end
    
    def define(context)
      yield self if block_given?
      @context = context
      index!
      show!
      update!
    end

    def index!
      map :get, "/#{prefix}" do |params|
        model.send(*finder).send as(params)
      end
    end
    
    def show!
      map :get, "/#{prefix}/:id" do |params|
        record = model.find(params[:id])
        record.send(as(params))
      end
    end
    
    def update!
      map :put, "/#{prefix}/:id" do |params|
        record = model.find(params[:id])
        record.attributes = parse_for_attributes!(params)
        record.save
        record.send(as(params))
      end
    end
    
    def finder
      options[:finder]
    end
    
    def options
      @options ||= {
        :finder => [:all]
      }
    end
    
    def map(verb, path, &block)
      context.send(verb, path) do
        throw :halt, [400, "\nYou must specify JSON or XML in your path. Example: #{path}.json\n"]
      end
      
      context.send(verb, "#{path}.:format") do
        throw :halt, [
          406, [
            "",
            "The '#{params[:format]}' format is not supported.",
            "You must specify JSON or XML in your path.\n",
            "Example: #{path}.json",
            "\n"
          ].join("\n")
        ] unless VALID_FORMATS.include?(params[:format])
        
        block.call(params)
      end
    end
    
    def parse_for_attributes!(params)
      string = params[prefix.singularize]
      case params[:format].to_sym
      when :json then JSON.parse(string)
      when :xml  then Hash.from_xml(string)['hash']
      end
    end
    
    def prefix
      Extlib::Inflection.tableize(model.name)
    end
    
    def as(params)
      "to_#{params[:format]}"
    end
  end
end

def mount(model, &block)
  Sinatra::Hat.new(model).define(self, &block)
end
