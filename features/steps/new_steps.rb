When /^I get the new page for that record$/ do
  get '/people/new'
end

When /^I get the new action with a valid format$/ do
  get '/people/new.xml'
end

When /^I get the new action with an invalid format$/ do
  get '/people/new.oops'
end

Then /^the new\.erb template is rendered$/ do
  body.should == "So, you want to create a new Person?"
end

Then /^the body is a serialized new record$/ do
  body.should == Person.new.to_xml
end
