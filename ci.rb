require 'rubygems'
require 'dash-ci'

CI.register('sinatras-hat') do
  build :specs, 'spec spec/'
  build :cucumber, 'cucumber -f progress features/'
end

CI.run('sinatras-hat', :token => ENV['DASH_TOKEN'])