def mount!
  mock_app do
    set :views, File.join(File.dirname(__FILE__), '..', 'support', 'views')
    # set :logging, true
    
    mount Person do
      mount Comment
    end
  end
end

Before do
  Person.delete_all
  Comment.delete_all
end

Given /^a model that has a record$/ do
  @record = Person.create! :name => "Pat"
end

Given /^the record has children$/ do
  @not_a_child = Comment.create! :name => "I should never show up!"
  @child_record = @record.comments.create! :name => "Commented!"
end

Given /^a model that does not have a record$/ do
  Person.all.should be_empty
  @record = Person.new
  class << @record
    def to_param
      "230934509834"
    end
  end
end

Given /^a mounted model$/ do
  mount!
end

Given /^I mount the model$/ do
  mount!
end
When /^I make a GET request for that record using the '(\w+)' format$/ do |format|
  get "/people/#{@record.to_param}.#{format}"
end

Then /^the body is empty$/ do
  body.should be_empty
end

Then /^the status code is (\d+)$/ do |code|
  response.status.should == code.to_i
end

Then /^the new\.erb template is rendered$/ do
  body.should == "So, you want to create a new Person?"
end