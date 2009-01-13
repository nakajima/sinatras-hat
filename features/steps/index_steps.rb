# TODO Use acts_as_fu to build some actual models to test

Given /^the model has some records$/ do
  @pat = Person.create :name => "Pat"
  @frank = Person.create :name => "Frank"
end

When /^I get the index with a known format$/ do
  get '/people.xml'
end

When /^I get the index without a format$/ do
  get '/people'
end

When /^I get the index with an unknown format$/ do
  get '/people.say_wha'
end

Then /^the result should be serialized$/ do
  @response.body.should == Person.all.to_xml
end

Then /^the index\.erb template should be rendered$/ do
  @response.body.should == "The people: #{Person.all.map(&:name).join(', ')}."
end
