$:.unshift File.expand_path('../lib', __FILE__)
require 'routing_filter/version'

Gem::Specification.new do |s|
  s.name         = "routing-filter"
  s.version      = RoutingFilter::VERSION
  s.authors      = ["Sven Fuchs"]
  s.email        = "svenfuchs@artweb-design.de"
  s.homepage     = "http://github.com/svenfuchs/routing-filter"
  s.summary      = "Routing filters wraps around the complex beast that the Rails routing system is, allowing for unseen flexibility and power in Rails URL recognition and generation"
  s.description  = "Routing filters wraps around the complex beast that the Rails routing system is, allowing for unseen flexibility and power in Rails URL recognition and generation."

  s.files        = Dir["{lib,test}/**/**"] + Dir['[A-Z]*']
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.rubyforge_project = '[none]'

  s.add_dependency 'actionpack', '>= 0'

  s.add_development_dependency 'i18n', '>= 0'
  s.add_development_dependency 'rails', '>= 0'
  s.add_development_dependency 'test_declarative', '>= 0'
end
