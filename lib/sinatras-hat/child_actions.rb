module Sinatra
  module Hat
    module ChildActions
      def generate_child_actions!
        children.each do |resource|
          only.each { |action| send("#{action}_child!", resource) }
        end
      end
      
      def index_child!(name)
        map :index, "/#{prefix}/:#{model_id}/#{name}", :view_as => name.to_s do |params|
          call :finder, params, :on => parent_model(params).send(name)
        end
      end
    
      def show_child!(name)
        map :show, "/#{prefix}/:#{model_id}/#{name}/:id", :view_as => name.to_s do |params|
          call(:record, params, :on => proxy_for(name, params))
        end
      end
          
      def create_child!(name)
        map :create, "/#{prefix}/:#{model_id}/#{name}", :verb => :post do |params|
          proxy = proxy_for(name, params)
          result = proxy.new
          result.attributes = parse_for_attributes(params, name).merge(model_id => parent_model(params).id)
          result.save
          result
        end
      end
          
      def update_child!(name)
        map :update, "/#{prefix}/:#{model_id}/#{name}/:id", :verb => :put do |params|
          proxy = proxy_for(name, params)
          result = call(:record, params, :on => proxy_for(name, params))
          result.attributes = parse_for_attributes(params, name).merge(model_id => parent_model(params).id)
          result.save
          result
        end
      end
          
      def destroy_child!(name)
        map :destroy, "/#{prefix}/:#{model_id}/#{name}/:id", :verb => :delete do |params|
          proxy = proxy_for(name, params)
          result = call(:record, params, :on => proxy_for(name, params))
          result.destroy
          :ok
        end
      end
      
      private
      
      def proxy_for(name, params)
        parent_model(params).send(name)
      end
      
      def parent_model(params)
        call(:record, :id => params[model_id])
      end
      
      def model_id
        "#{model.name.downcase}_id"
      end
    end
  end
end