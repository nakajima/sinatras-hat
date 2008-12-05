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
        map :index, resource_path('/') do |params|
          call(:finder, params)
        end
      end
    
      def show!
        map :show, resource_path('/:id') do |params|
          call(:record, params)
        end
      end
    
      def create!
        map :create, resource_path('/'), :verb => :post do |params|
          result = proxy(params).new
          result.attributes = parse_for_attributes(params)
          result.save
          result
        end
      end
    
      def update!
        map :update, resource_path('/:id'), :verb => :put do |params|
          result = call(:record, params)
          result.attributes = parse_for_attributes(params)
          result.save
          result
        end
      end
    
      def destroy!
        map :destroy, resource_path('/:id'), :verb => :delete do |params|
          result = call(:record, params)
          result.destroy
          :ok
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