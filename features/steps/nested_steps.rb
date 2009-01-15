When /^Make a GET request to the nested index without a format$/ do
  get "/people/#{@record.id}/comments"
end

When /^Make a GET request to the nested index with a valid format$/ do
  get "/people/#{@record.id}/comments.xml"
end

Then /^the nested resource index\.erb template should be rendered$/ do
  @response.body.should include('The nested view!')
  @response.body.should =~ /#{@child_record.name}/
end


Then /^the body is the serialized list of children$/ do
  @response.body.should == @record.comments.to_xml
end
