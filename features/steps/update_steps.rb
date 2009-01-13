When /^I make a put request with valid form params$/ do
  put "/people/#{@record.to_param}?person[name]=UPDATED"
end

When /^I make a PUT request with invalid form params$/ do
  put "/people/#{@record.to_param}?person[name]="
end

Then /^the record is updated$/ do
  @record.reload
  @record.name.should == "UPDATED"
end

Then /^the response redirects to the record show page$/ do
  response.status.should == 302
  response.location.should == "/people/#{@record.to_param}"
end

Then /^the record is not updated$/ do
  @record.reload
  @record.name.should == "Pat"
end