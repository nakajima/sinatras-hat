Given /^a model that has a record$/ do
  Person.delete_all
  @pat = Person.create! :name => "Pat"
end

Given /^a model that does not have a record$/ do
  Person.delete_all
end

Given /^a mounted model$/ do
  Person.delete_all
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

Then /^the body is empty$/ do
  body.should be_empty
end

Then /^the status code is (\d+)$/ do |code|
  response.status.should == code.to_i
end

Then /^the new\.erb template is rendered$/ do
  body.should == "So, you want to create a new Person?"
end