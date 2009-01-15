require File.join(File.dirname(__FILE__), *%w[.. .. spec spec_helper])

Sinatra::Test.tap do |mod|
  mod.module_eval { remove_method(:should) }
  include mod
end

require 'spec/expectations'
require 'acts_as_fu'

include ActsAsFu

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