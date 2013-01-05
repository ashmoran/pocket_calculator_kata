guard 'rspec', cli: "--color --format Fuubar" do
  watch(%r{^spec/.+_spec\.rb})
  watch(%r{^spec/.+_contract\.rb})  { "spec" }
  watch(%r{^lib/(.+)\.rb})          { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')      { "spec" }
  watch(%r{spec/support/.+\.rb})    { "spec" }
end
