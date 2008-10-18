module Sinatra
  module Hat
    module ChildActions
      def generate_child_actions!
        children.each do |resource|
          only.each { |action| send("#{action}_child!", resource) }
        end
      end
      
      def index_child!(name)
        map :index, "/#{prefix}/:id/#{name}" do |params|
          call(:record, params).send(name)
        end
      end
    
      def show_child!(name)
        map :show, "/#{prefix}/:#{model_id}/#{name}/:id" do |params|
          call(:record, params, :on => proxy_for(name, params))
        end
      end
          
      def create_child!(name)

      end
          
      def update_child!(name)

      end
          
      def destroy_child!(name)

      end
      
      private
      
      def proxy_for(name, params)
        call(:record, :id => params[model_id]).send(name)
      end
      
      def model_id
        "#{model.name.downcase}_id"
      end
    end
  end
end