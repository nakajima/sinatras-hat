When /^Make a GET request to the nested index without a format$/ do
  get "/people/#{@record.id}/comments"
end

When /^Make a GET request to the nested index with a valid format$/ do
  get "/people/#{@record.id}/comments.xml"
end

Then /^the body is the serialized list of children$/ do
  @response.body.should == @record.comments.to_xml
end
