module Sinatra
  module Hat
    module Actions
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
    end
  end
end