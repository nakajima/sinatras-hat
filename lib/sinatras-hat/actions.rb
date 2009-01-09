Sinatra::Hat::Maker.class_eval do
  action :index do |request|
    data = model.all(request.params)

    responder.handle(:index, request, data)
  end
  
  action :show do |request|
    data = model.find(request.params)
    
    responder.handle(:show, request, data)
  end
  
  action :create do |request|
    data = model.new(request.params)
    data.save
    responder.handle(:create, request, data) do |response|
      response.redirect(request, resource_path("/:id", data))
    end
  end
end