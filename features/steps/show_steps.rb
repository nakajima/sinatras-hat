# TODO Use acts_as_fu to build some actual models to test

Given /^a model that has a record$/ do
  Person.delete_all
  @pat = Person.create! :name => "Pat"
end

Given /^a model that does not have a record$/ do
  Person.delete_all
end

When /^I get the show page for that record$/ do
  get "/people/#{@pat.to_param}"
end

When /^I get the show page for the invalid record$/ do
  get "/people/87345873485763485"
end

Then /^the show\.erb template is rendered$/ do
  body.should == "The person: #{@pat.name}."
end

Then /^the status code is 404$/ do
  response.status.should == 404
end

Then /^the body is empty$/ do
  body.should be_empty
end
