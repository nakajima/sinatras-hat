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

When /^I get the show page for the non\-existent record$/ do
  get "/people/87345873485763485"
end

When /^I make a request for that record with a format$/ do
  get "/people/#{@pat.to_param}.xml"
end

When /^I get the show page for the non\-existent record with a format$/ do
  get "/people/87345873485763485.xml"
end

Then /^the show\.erb template is rendered$/ do
  body.should == "The person: #{@pat.name}."
end

Then /^the body is empty$/ do
  body.should be_empty
end

Then /^the status code is (\d+)$/ do |code|
  response.status.should == code.to_i
end

Then /^the body is the serialized record$/ do
  body.should == @pat.to_xml
end
