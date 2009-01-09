Sinatra::Hat::Maker.class_eval do
  action :new, '/new' do |request|
    data = model.new(request.params)
    responder.success(:new, request, data)
  end
  
  action :show, '/:id' do |request|
    data = model.find(request.params)
    responder.success(:show, request, data)
  end
  
  action :create, '/', :verb => :post do |request|
    data = model.new(request.params)
    result = data.save ? :success : :failure
    responder.send(result, :create, request, data)
  end
  
  action :index, '/' do |request|
    data = model.all(request.params)
    responder.success(:index, request, data)
  end
end