Given /^I mount the model protecing the show action$/ do
  @app = mock_app do
    set :views, File.join(File.dirname(__FILE__), '..', 'support', 'views')
    # set :logging, true
    
    mount Person do
      protect :show
    end
  end
end
