source "https://rubygems.org"

gemspec

if RUBY_VERSION < '1.9.3'
  gem 'activesupport', '< 4.0.0'
end

group :test do
  gem 'ruby-debug', :platforms => :mri_18
  gem 'debugger', :platforms => :mri_19
end
