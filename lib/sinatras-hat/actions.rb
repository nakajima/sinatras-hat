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
          set :result, model.find(request.params)
          result.destroy rescue nil
          set :success, true
        end
        
        map.action :new, '/new' do |request|
          set :result, model.new(request.params)
          set :success, true
        end
        
        map.action :update, '/:id', :verb => :put do |request|
          set :result, model.update(request.params)
          set :success, result.save rescue false
        end
        
        map.action :edit, '/:id/edit' do |request|
          set :result, model.find(request.params)
          set :success, true
        end

        map.action :show, '/:id' do |request|
          set :result, model.find(request.params)
          set :success, result
        end
        
        map.action :create, '/', :verb => :post do |request|
          record = model.new(request.params)
          set :success, record.save
          set :result, record
        end

        map.action :index, '/' do |request|
          set :result, model.all(request.params)
          set :success, true
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