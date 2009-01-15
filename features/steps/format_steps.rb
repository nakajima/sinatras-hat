Given /^specify a custom 'ruby' formatter$/ do
  # this is implemented in common_steps.rb
end

Then /^the body is the custom serialized record$/ do
  @response.body.should == @record.inspect
end

Then /^the result should be custom serialized$/ do
  @response.body.should == Person.all.inspect
end
