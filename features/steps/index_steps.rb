Given /^a model that has some records$/ do
  Article.all.should == [:first_article, :second_article]
end

Given /^I mount the model$/ do
  @app = mock_app do
    mount(Article)
  end
end

When /^I get the index with a known format$/ do
  get '/articles.yaml'
end

When /^I get the index without a format$/ do
  get '/articles'
end

Then /^the result should be serialized$/ do
  @response.body.should == [:first_article, :second_article].to_yaml
end

Then /^the index\.erb template should be rendered$/ do
  @response.body.should == "HEY: [:first_article, :second_article]"
end