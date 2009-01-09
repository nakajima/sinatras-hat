module Sinatra
  module Hat
    # Contains all of the actions that Sinatra's Hat supports.
    # Each action states a name, a path, optionally, the HTTP
    # verb, then a block which takes a request object, optionally
    # loads data using the :finder or :record options, then
    # responds, based on whether or not the action was a success
    # 
    # NOTE: only the :create action renders a different :failure
    module Actions
      def self.included(map)
        map.action :destroy, '/:id', :verb => :delete do |request|
          data = model.find(request.params)
          data.destroy
          responder.success(:destroy, request, data)
        end
        
        map.action :new, '/new' do |request|
          data = model.new(request.params)
          responder.success(:new, request, data)
        end
        
        map.action :update, '/:id', :verb => :put do |request|
          data = model.update(request.params)
          result = data.save ? :success : :failure
          responder.send(result, :update, request, data)
        end
        
        map.action :edit, '/:id/edit' do |request|
          data = model.find(request.params)
          responder.success(:edit, request, data)
        end

        map.action :show, '/:id' do |request|
          data = model.find(request.params)
          responder.success(:show, request, data)
        end
        
        map.action :create, '/', :verb => :post do |request|
          data = model.new(request.params)
          result = data.save ? :success : :failure
          responder.send(result, :create, request, data)
        end

        map.action :index, '/' do |request|
          data = model.all(request.params)
          responder.success(:index, request, data)
        end
      end
    end
  end
end