module Sinatra
  module Hat
    module Actions
      def generate_actions!
        only.each { |action| send("#{action}!") }
        children.each do |resource|
          mount(resource)
        end
      end
      
      def index!
        map :index, '/' do |params|
          call(:finder, params)
        end
      end
    
      def new!
        map :new, '/new' do |params|
          proxy(params).new
        end
      end
      
      def edit!
        map :edit, '/:id/edit' do |params|
          call(:record, params)
        end
      end
    
      def show!
        map :show, '/:id' do |params|
          call(:record, params)
        end
      end
    
      def create!
        map :create, '/', :verb => :post do |params|
          create[proxy(params), params]
        end
      end
    
      def update!
        map :update, '/:id', :verb => :put do |params|
          update[call(:record, params), params]
        end
      end
    
      def destroy!
        map :destroy, '/:id', :verb => :delete do |params|
          destroy[call(:record, params), params]
        end
      end
      
      private
      
      def parse_for_attributes(params, name=model.name.downcase)
        if handler = accepts[params[:format].try(:to_sym)]
          handler.call params[name]
        else
          params.nest!
          params[name] ||= { }
          params[name][parent.model_id] = params[parent.model_id] if parent
          params[name]
        end
      end
    end
  end
end