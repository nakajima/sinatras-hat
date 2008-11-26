require File.join(File.dirname(__FILE__), 'spec_helper')

describe Sinatra::Hat::Actions, '#show' do
  attr_reader :response, :record

  describe "destroy" do
    it "should destroy a record" do
      mock(record).destroy
      mock(Foo).first(:id => '3').returns(record)
      delete_it '/foos/3'
      response.should be_redirect
    end
  end
end