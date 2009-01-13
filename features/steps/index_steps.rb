# TODO Use acts_as_fu to build some actual models to test

Given /^a model that has some records$/ do
  Person.delete_all
  @pat = Person.create :name => "Pat"
  @frank = Person.create :name => "Frank"
  Person.all.should have(2).people
  Person.all.should include(@pat, @frank)
end

Given /^I mount the model$/ do
  mock_app do
    mount Person do
      finder { |model, params| model.all }
      record { |model, params| model.find_by_id(params[:id]) }
    end
  end
end

When /^I get the index with a known format$/ do
  get '/people.xml'
end

When /^I get the index without a format$/ do
  get '/people'
end

When /^I get the index with an unknown format$/ do
  get '/people.say_wha'
end

Then /^the result should be serialized$/ do
  @response.body.should == Person.all.to_xml
end

Then /^the index\.erb template should be rendered$/ do
  @response.body.should == "The people: #{Person.all.map(&:name).join(', ')}."
end
