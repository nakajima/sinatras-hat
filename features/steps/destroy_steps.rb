When /^I make a DELETE request to the path for that record$/ do
  delete "/people/#{@record.to_param}"
end

When /^I make a DELETE request to a path for a non\-existent record$/ do
  delete "/people/345345435"
end

Then /^the record gets destroyed$/ do
  Person.find_by_id(@record.id).should be_nil
end

Then /^I am redirected to the index action$/ do
  response.status.should == 302
  response.location.should == '/people'
end
