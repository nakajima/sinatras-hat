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
          record = model.find(request.params) || request.not_found
          record.destroy
          responder.success(:destroy, request, record)
        end
        
        map.action :new, '/new' do |request|
          new_record = model.new(request.params)
          responder.success(:new, request, new_record)
        end
        
        map.action :update, '/:id', :verb => :put do |request|
          record = model.update(request.params) || request.not_found
          result = record.save ? :success : :failure
          responder.send(result, :update, request, record)
        end
        
        map.action :edit, '/:id/edit' do |request|
          record = model.find(request.params) || request.not_found
          responder.success(:edit, request, record)
        end

        map.action :show, '/:id' do |request|
          record = model.find(request.params) || request.not_found
          set_cache_headers(request, record) unless protected?(:show)
          responder.success(:show, request, record)
        end
        
        map.action :create, '/', :verb => :post do |request|
          record = model.new(request.params)
          result = record.save ? :success : :failure
          responder.send(result, :create, request, record)
        end

        map.action :index, '/' do |request|
          records = model.all(request.params)
          set_cache_headers(request, records) unless protected?(:index)
          responder.success(:index, request, records)
        end
        
        private
        
        def set_cache_headers(request, data)
          
          set_etag(request, data)
          set_last_modified(request, data)
        end
        
        def set_etag(request, data)
          record = model.find_last_modified(Array(data))
          return unless record.respond_to?(:updated_at)
          request.etag("#{record.id}-#{record.updated_at}-#{data.is_a?(Array)}")
        end
        
        def set_last_modified(request, data)
          record = model.find_last_modified(Array(data))
          return unless record.respond_to?(:updated_at)
          request.last_modified(record.updated_at)
        end
      end
    end
  end
end