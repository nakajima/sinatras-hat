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
          record = model.find(request.params) || responder.not_found(request)
          record.destroy
          responder.success(:destroy, request, record)
        end
        
        map.action :new, '/new' do |request|
          new_record = model.new(request.params)
          responder.success(:new, request, new_record)
        end
        
        map.action :update, '/:id', :verb => :put do |request|
          record = model.update(request.params) || responder.not_found(request)
          result = record.save ? :success : :failure
          responder.send(result, :update, request, record)
        end
        
        map.action :edit, '/:id/edit' do |request|
          record = model.find(request.params) || responder.not_found(request)
          responder.success(:edit, request, record)
        end

        map.action :show, '/:id' do |request|
          record = model.find(request.params) || responder.not_found(request)
          responder.success(:show, request, record)
        end
        
        map.action :create, '/', :verb => :post do |request|
          record = model.new(request.params)
          result = record.save ? :success : :failure
          responder.send(result, :create, request, record)
        end

        map.action :index, '/' do |request|
          records = model.all(request.params)
          responder.success(:index, request, records)
        end
      end
    end
  end
end