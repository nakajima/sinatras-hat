Given /^I mount the model for only the :index action$/ do
  @app = mock_app do
    set :views, File.join(File.dirname(__FILE__), '..', 'support', 'views')
    # set :logging, true
    
    mount Person do
      only :index
    end
  end
end