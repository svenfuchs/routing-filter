require 'bundler/setup'
require 'appraisal'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'lib' << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

desc "Default: run the unit tests."
task :default => [:all]

desc 'Test the plugin under all supported Rails versions.'
task :all => ["appraisal:install"] do |t|
  if RUBY_VERSION < '1.9.3'
    exec('rake appraisal:rails-2.3 test')
    exec('rake appraisal:rails-3.0 test')
    exec('rake appraisal:rails-3.1 test')
    exec('rake appraisal:rails-3.2 test')
  elsif RUBY_VERSION > '1.9.3'
    exec('rake appraisal:rails-3.0 test')
    exec('rake appraisal:rails-3.1 test')
    exec('rake appraisal:rails-3.2 test')
    exec('rake appraisal:rails-4.0 test')
  else
    exec('rake appraisal test')
  end
end
