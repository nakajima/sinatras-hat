# TODO Use acts_as_fu to build some actual models to test

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

Then /^the body is the serialized record$/ do
  body.should == @pat.to_xml
end

# Then /^the body is the custom serialized record$/ do
# end
