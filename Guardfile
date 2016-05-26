guard :rspec, all_on_start: true, cmd: "bundle exec rspec" do
  watch(%r{^spec/.+\.rb$})  { "spec" }
  watch(%r{^lib/(.+)\.rb$})  { "spec" }
  watch('spec/spec_helper.rb')  { "spec" }
end
