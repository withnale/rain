When /^I get help for "([^"]*)"$/ do |app_name|
  @app_name = app_name
  step %(I run `#{app_name} help`)
end

# Add more step definitions here

Given /^the input "(.*?)"$/ do |arg1|
  @params = arg1
end

When /^rain is run$/ do
  @stdout = step %(I run `./bin/rain #{@params}`)
end

Given(/^that I am using embedded test data '(.*)'$/) do |arg1|
  Rain::Config.stub(:zonepaths) do
    [ File.expand_path("./etc/testdata/#{arg1}", Rain::Config.basedir)]
  end
end

=begin
Given(/^1that I am using embedded test data '(.*)'$/) do |arg1|
  expect(Rain::Config).to receive(:zonepaths).at_least(0).times do
    [ File.expand_path("./etc/testdata/#{arg1}", Rain::Config.basedir)]
  end
end
=end

Then /^the output should have (\d+) lines$/ do |arg|
  all_output.lines.count.should == arg.to_i
end



Then /^the output should match the file '(.*)'$/ do |location|
  raw_text = File.open("./features/output/#{location}", 'rb').read
  assert_exact_output(raw_text, all_output)
end

Then /^print the output$/ do
  puts all_output
end