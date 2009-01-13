Before do
  Person.delete_all
end

Given /^a model that has a record$/ do
  @pat = Person.create! :name => "Pat"
end

Given /^a model that does not have a record$/ do
  Person.all.should be_empty
end

Given /^a mounted model$/ do
  mock_app do
    mount Person do
      finder { |model, params| model.all }
      record { |model, params| model.find_by_id(params[:id]) }
    end
  end
end

Given /^I mount the model$/ do
  mock_app do
    mount Person do
      finder { |model, params| model.all }
      record { |model, params| model.find_by_id(params[:id]) }
    end
  end
end

When /^I make a request for that record using the '(\w+)' format$/ do |format|
  get "/people/#{@pat.to_param}.#{format}"
end

Then /^the body is empty$/ do
  body.should be_empty
end

Then /^the status code is (\d+)$/ do |code|
  response.status.should == code.to_i
end

Then /^the new\.erb template is rendered$/ do
  body.should == "So, you want to create a new Person?"
end