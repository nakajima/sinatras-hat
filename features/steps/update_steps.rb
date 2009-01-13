When /^I make a put request with valid form params$/ do
  put "/people/#{@pat.to_param}?person[name]=UPDATED"
end

Then /^the record is updated$/ do
  @pat.reload
  @pat.name.should == "UPDATED"
end

Then /^the response redirects to the record show page$/ do
  response.status.should == 302
  response.location.should == "/people/#{@pat.to_param}"
end
