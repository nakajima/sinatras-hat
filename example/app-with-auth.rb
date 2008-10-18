require File.dirname(__FILE__) + '/lib/common.rb'

mount(Post) do
  protect :all,
    :username => 'bliggety',
    :password => 'blam',
    :realm => "Use Protection"
end
