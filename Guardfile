# -*- ruby -*-

guard 'rspec', cmd: 'bundle exec rspec', all_after_pass: false do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})             { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/sycamore/(.+)\.rb$})    { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/sycamore/path.rb$})     { "spec/sycamore/path_root_spec.rb" }
  watch(%r{^lib/sycamore/tree.rb$})     { "spec/sycamore/absence_spec.rb" }
  watch('spec/spec_helper.rb')          { 'spec' }
  watch(/spec\/support\/(.+)\.rb/)      { 'spec' }
end
