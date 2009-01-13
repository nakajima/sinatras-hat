When /^I make a POST request with valid form params$/ do
  post "/people?person[name]=Pat"
end

Then /^a record is created$/ do
  @pat = Person.find_by_name("Pat")
  @pat.should_not be_nil
end