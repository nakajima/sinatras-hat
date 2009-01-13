# TODO Use acts_as_fu to build some actual models to test

Given /^a model that has a record$/ do
  Article.first(:id => 2).should_not be_nil
end

Given /^a model that does not have a record$/ do
  Article.first(:id => 1).should be_nil
end

When /^I get the show page for that record$/ do
  get "/articles/2"
end

When /^I get the show page for the invalid record$/ do
  get "/articles/1"
end

Then /^the show\.erb template is rendered$/ do
  body.should == "SHOW: #{Article.first(:id => 2).inspect}"
end

# Then /^the status code is 404$/ do
#   response.status.should == 404
# end
