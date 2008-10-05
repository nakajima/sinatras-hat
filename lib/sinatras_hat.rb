require 'erb'
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
      map :index, "/#{prefix}" do |params|
        finder.call(params)
      end
    end
    
    def show!
      map :show, "/#{prefix}/:id" do |params|
        result = record.call(params)
        result
      end
    end
    
    def create!
      map :create, "/#{prefix}", :verb => :post do |params|
        result = model.new
        result.attributes = parse_for_attributes!(params)
        result.save
        result
      end
    end
    
    def update!
      map :update, "/#{prefix}/:id", :verb => :put do |params|
        result = record.call(params)
        result.attributes = parse_for_attributes!(params)
        result.save
        result
      end
    end
    
    def destroy!
      map :destroy, "/#{prefix}/:id", :no_format => true, :verb => :delete do |params|
        result = record.call(params)
        result.destroy
        :ok
      end
    end

    def accepts
      @accepts ||= {
        :yaml => proc { |string| YAML.load(string) },
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
        :only => [:show, :create, :update, :destroy, :index],
        :renderer => :erb,
        :prefix => Extlib::Inflection.tableize(model.name)
      }
    end
    
    def map(name, path, opts={}, &block)
      opts[:no_format] ? 
        handle_without_format(name, path, opts, &block) : 
        handle_with_format(name, path, opts, &block)
    end
    
    def render_template(context, name, verb, &block)
      template_root = File.join(Sinatra.application.options.views, prefix)
      template_path = File.join(template_root, "#{name}.#{renderer}")
      params = railsify_params(context.params)
      result = block.call(params)
      context.instance_variable_set ivar_name(result), result
      return verb == :get ?
        context.render(renderer, name, :views_directory => template_root) :
        context.redirect(redirection_path(result))
      throw :halt, [500, "Couldn't find template: #{template_path}"]
    end
    
    def render_format(context, format, verb, &block)
      if accepts[format] or verb.eql?(:get)
        object = block.call(context.params)
        handle = formats[format]
        result = handle ? handle.call(object) : object.try("to_#{format}")
        return result unless result.nil?
      end
      
      throw :halt, [
        406, [
          "The `#{format}` format is not supported.\n",
          "Valid Formats: #{accepts.keys.join(', ')}\n",
        ].join("\n")
      ]
    end
    
    private
    
    def railsify_params(params)
      new_params = {} 
      params.each_pair do |full_key, value| 
        this_param = new_params 
        split_keys = full_key.split(/\]\[|\]|\[/) 
        split_keys.each_index do |index| 
          break if split_keys.length == index + 1 
          this_param[split_keys[index]] ||= {} 
          this_param = this_param[split_keys[index]] 
        end 
        this_param[split_keys.last] = value 
      end 
      params.clear
      params.merge! new_params 
      params
    end
    
    def handle_without_format(name, path, opts, &block)
      context.send(opts[:verb], path) do
        block.call(params)
      end
    end
    
    def handle_with_format(name, path, opts, &block)
      verb = opts[:verb] || :get
      klass = self
      
      handler = proc do
        format = request.env['PATH_INFO'].split('.')[1]
        format ? 
          klass.render_format(self, format.to_sym, verb, &block) :
          klass.render_template(self, name, verb, &block)
      end
      
      context.send(verb, path, &handler)
      context.send(verb, "#{path}.:format", &handler)
    end
    
    def redirection_path(result)
      result.is_a?(Symbol) ?
        "/#{prefix}" :
        "/#{prefix}/#{result.id}"
    end
    
    def plural?(result)
      result.respond_to?(:length)
    end
    
    def ivar_name(result)
      "@" + (plural?(result) ? prefix : model.name.downcase)
    end
    
    def parse_for_attributes!(params)
      if handler = accepts[params[:format].try(:to_sym)]
        handler.call params[prefix.singularize]
      else
        params[model.name.downcase]
      end
    end
  end
end

def mount(model, opts={}, &block)
  Sinatra::Hat.new(model).define(self, opts, &block)
end
