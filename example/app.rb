require File.dirname(__FILE__) + '/lib/common.rb'

mount(Post) do
  mount(Comment)
  
  # Allows for params[:post] to just be a YAML string which will
  # get parsed into an attributes hash for updating a record
  accepts[:yaml] = proc { |content| YAML.load(content) }
  
  # Allows for a custom response format for when requests come in
  # as .ruby
  Rack::File::MIME_TYPES['ruby'] = 'text/x-ruby'
  formats[:ruby] = proc { |content| content.inspect }
end
