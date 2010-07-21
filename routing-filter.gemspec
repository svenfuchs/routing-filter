$:.unshift File.expand_path('../lib', __FILE__)
require 'routing_filter/version'

Gem::Specification.new do |s|
  s.name         = "routing_filter"
  s.version      = RoutingFilter::VERSION
  s.authors      = ["Sven Fuchs"]
  s.email        = "svenfuchs@artweb-design.de"
  s.homepage     = "http://github.com/svenfuchs/routing_filter"
  s.summary      = "Routing filters wraps around the complex beast that the Rails routing system is, allowing for unseen flexibility and power in Rails URL recognition and generation"
  s.description  = "Routing filters wraps around the complex beast that the Rails routing system is, allowing for unseen flexibility and power in Rails URL recognition and generation."

  s.files        = `git ls-files {app,lib}`.split("\n")
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.rubyforge_project = '[none]'

  s.add_dependency             'action_pack', '>= 3.0.0.beta4'
  s.add_dependency             'activesupport'
  s.add_development_dependency 'test_declarative'
end
