When /^I get the edit page for that record$/ do
  get "/people/#{@pat.to_param}/edit"
end

When /^I get the show page for a non\-existent record$/ do
  get "/people/23472398732498734/edit"
end

Then /^the edit\.erb template is rendered$/ do
  body.should == "Editing #{@pat.name}."
end
