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
    
    def define(context)
      yield self if block_given?
      @context = context
      index!
      show!
      update!
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
    
    def update!
      map :put, "/#{prefix}/:id" do |params|
        record = model.find(params[:id])
        record.attributes = parse_for_attributes!(params)
        record.save
        record
      end
    end
    
    def finder
      options[:finder]
    end
    
    def formats
      @formats ||= {
        :json => proc { |string| JSON.parse(string) },
        :xml  => proc { |string| Hash.from_xml(string)['hash'] }
      }
    end
    
    def options
      @options ||= {
        :finder => [:all]
      }
    end
    
    def map(verb, path, &block)
      valid_formats = formats
      
      context.send(verb, path) do
        throw :halt, [400, "\nYou must specify JSON or XML in your path. Example: #{path}.json\n"]
      end
      
      context.send(verb, "#{path}.:format") do
        format = params[:format].downcase.to_sym
        
        next block.call(params).send("to_#{format}") if valid_formats[format]
        
        throw :halt, [
          406, [
            "",
            "The '#{format}' format is not supported.",
            "You must specify JSON or XML in your path.\n",
            "Example: #{path}.json",
            "\n"
          ].join("\n")
        ]
      end
    end
    
    def parse_for_attributes!(params)
      handler = formats[params[:format].to_sym]
      handler.call params[prefix.singularize]
    end
    
    def prefix
      Extlib::Inflection.tableize(model.name)
    end
  end
end

def mount(model, &block)
  Sinatra::Hat.new(model).define(self, &block)
end
