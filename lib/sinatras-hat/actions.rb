module Sinatra
  module Hat
    module Actions
      def self.included(map)
        map.action :new, '/new' do |request|
          data = model.new(request.params)
          responder.success(:new, request, data)
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