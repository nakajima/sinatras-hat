Then /^"(.*)" should be the record "(.*)" time$/ do |header, key|
  DateTime.parse(response.headers[header].to_s).should == @record.send(key)
end
