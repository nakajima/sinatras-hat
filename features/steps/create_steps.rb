When /^I make a POST request with valid form params$/ do
  post "/people?person[name]=Pat"
end

When /^I make a POST request with invalid form params$/ do
  post "/people?person[name]="
end

# When /^I make a POST request with valid serialized attributes for a valid format$/ do
#   post "/people.xml", ({:person => { :name => "Pat" }}).to_xml
# end

Then /^a record is created$/ do
  @pat = Person.find_by_name("Pat")
  @pat.should_not be_nil
end

Then /^a record is not created$/ do
  @pat = Person.find_by_name("Pat")
  @pat.should be_nil
end
