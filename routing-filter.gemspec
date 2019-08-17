$:.unshift File.expand_path('../lib', __FILE__)
require 'routing_filter/version'

rails_version = ['>= 4.2']

Gem::Specification.new do |s|
  s.name         = "routing-filter"
  s.version      = RoutingFilter::VERSION
  s.authors      = ["Sven Fuchs"]
  s.email        = "svenfuchs@artweb-design.de"
  s.homepage     = "http://github.com/svenfuchs/routing-filter"
  s.summary      = "Routing filters wraps around the complex beast that the Rails routing system is, allowing for unseen flexibility and power in Rails URL recognition and generation"
  s.description  = "Routing filters wraps around the complex beast that the Rails routing system is, allowing for unseen flexibility and power in Rails URL recognition and generation."

  s.files        = Dir['CHANGELOG.md', 'README.markdown', 'MIT-LICENSE', 'lib/**/*']
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.rubyforge_project = '[none]'
  s.required_ruby_version = '>= 2.0'

  s.add_dependency 'actionpack', rails_version
  s.add_dependency 'activesupport', rails_version

  s.add_development_dependency 'i18n'
  s.add_development_dependency 'test_declarative'
  s.add_development_dependency 'rack-test', '~> 0.6.2'
  s.add_development_dependency 'rails', rails_version
  s.add_development_dependency 'minitest', '< 5.10.2'
end
