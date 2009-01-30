Before do
  build_model(:people) do
    string :name

    has_many :comments

    validates_presence_of :name
  end

  build_model(:comments) do
    integer :person_id
    string :name

    belongs_to :person
  end
    
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
  mock_app do
    set :views, File.join(File.dirname(__FILE__), '..', 'support', 'views')
    # set :logging, true

    mount Person do
      mount Comment

      formats[:ruby] = proc { |data| data.inspect }
    end
  end
end

Given /^I mount the model$/ do
  Given "a mounted model"
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

Then /^I should see "(.*)"$/ do |text|
  body.should =~ /#{text}/
end